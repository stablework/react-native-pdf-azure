import UIKit
import PDFKit
import PencilKit

class PDFViewController: UIViewController {

    var pdfView: PDFView!
    var canvasView: PKCanvasView!
    var editButton: UIButton!
    var pdfDocument: PDFDocument!
    var selectedPDFURL: URL?
    var isAnnotationEditing = false  // Renamed from 'isEditing' to avoid conflict

    // Initialize the selectedPDFURL from another view controller
    init(selectedPDFURL: URL) {
        super.init(nibName: nil, bundle: nil)
        self.selectedPDFURL = selectedPDFURL
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and configure the PDFView
        pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoScales = true
        self.view.addSubview(pdfView)

        // Create and configure the PencilKit canvas view
        canvasView = PKCanvasView(frame: self.view.bounds)
        canvasView.isHidden = true // Hide initially
        canvasView.backgroundColor = .clear // Set background to clear to show PDF underneath
        self.view.addSubview(canvasView)

        // Create an Edit button
        editButton = UIButton(frame: CGRect(x: 20, y: 40, width: 100, height: 50))
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(toggleEditing), for: .touchUpInside)
        editButton.backgroundColor = .blue
        self.view.addSubview(editButton)

        // Check if the selected PDF URL is set
        if let url = selectedPDFURL {
            pdfDocument = PDFDocument(url: url)
            pdfView.document = pdfDocument
        }
    }

    @objc func toggleEditing() {
        isAnnotationEditing.toggle() // Use the renamed variable

        if isAnnotationEditing {
            // Show the PencilKit canvas for editing (on top of PDF view) and keep the PDFView visible
            canvasView.isHidden = false
            editButton.setTitle("Save", for: .normal)
        } else {
            // Hide the PencilKit canvas and show PDF view again
            canvasView.isHidden = true
            editButton.setTitle("Edit", for: .normal)

            // Save the drawing to the PDF
            saveDrawing()
        }
    }

    func saveDrawing() {
        // Iterate through all pages in the PDF
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let pdfPage = pdfDocument.page(at: pageIndex) else { continue }

            // Convert the PencilKit drawing into an image
            let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)

            // Create a PDF annotation with the drawing image
            let annotation = createPDFAnnotation(image: drawingImage, page: pdfPage)

            // Add the annotation to the PDF page
            pdfPage.addAnnotation(annotation)
        }

        // Optionally, you can save the modified PDF to a new file
        savePDF()
    }

    func createPDFAnnotation(image: UIImage, page: PDFPage) -> PDFAnnotation {
        // Create a PDFAnnotation with custom drawing
        let annotation = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height), forType: .stamp, withProperties: nil)

        // Create an image context and draw the image
        UIGraphicsBeginImageContextWithOptions(annotation.bounds.size, false, 0.0)
        image.draw(in: annotation.bounds)
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Assign the drawn image to the annotation's content
//        annotation.image = drawnImage
        return annotation
    }

    func savePDF() {
        // Save the modified PDF with annotations
        if let modifiedPDFData = pdfDocument.dataRepresentation() {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("modified_pdf.pdf")
            do {
                try modifiedPDFData.write(to: fileURL)
                print("PDF saved at: \(fileURL)")
            } catch {
                print("Error saving PDF: \(error.localizedDescription)")
            }
        }
    }
}
