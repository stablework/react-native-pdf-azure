import { app, InvocationContext } from "@azure/functions";
import { BlobServiceClient } from "@azure/storage-blob";

const blobServiceClient = BlobServiceClient.fromConnectionString(process.env.AzureWebJobsStorage!);

export async function BlobTriggerFunction(blob: Buffer, context: InvocationContext): Promise<void> {
    const fileName = context.triggerMetadata.name as string;
    const requestId = context.invocationId;
    const containerName = "test1";

    let triggerType = "New blob detected"; // Default: Assume new blob

    try {
        const containerClient = blobServiceClient.getContainerClient(containerName);
        const blobClient = containerClient.getBlobClient(fileName);

        // 🔹 Step 1: Get Blob Properties to Check Last Modified Timestamp
        const properties = await blobClient.getProperties();

        const lastModifiedTime = properties.lastModified;
        const currentTime = new Date();
        const threshold = 10000; // 10 seconds threshold to differentiate new vs. updated

        // 🔹 Step 2: Check if Blob is New or Updated based on lastModified Time
        const timeDifference = currentTime.getTime() - lastModifiedTime.getTime();
        const isNewBlob = timeDifference <= threshold;

        if (!isNewBlob) {
            triggerType = "Blob updated"; // Blob was modified previously
        }
    } catch (error) {
        context.log(`Error checking blob metadata: ${error instanceof Error ? error.message : error}`);
    }

    // 🔹 Step 3: Log the Correct Trigger Type
    context.log(`(Type='${triggerType}', Id=${requestId}): Processed blob "${fileName}" with size ${blob.length} bytes`);
}

app.storageBlob('BlobTriggerFunction', {
    path: 'test1/{name}',  
    connection: 'AzureWebJobsStorage',
    handler: BlobTriggerFunction
});
