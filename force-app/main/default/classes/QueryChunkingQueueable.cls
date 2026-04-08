public with sharing class QueryChunkingQueueable implements Queueable {
    private Database.Cursor locator;
    private Integer position;

    public QueryChunkingQueueable() {
        locator = Database.getCursor(
            'SELECT Id FROM Contact WHERE LastActivityDate = LAST_N_DAYS:400',
            AccessLevel.USER_MODE);
        position = 0;
    }

    public void execute(QueueableContext ctx) {
        Integer remainingRows = locator.getNumRecords() - position;
        if (remainingRows == 0) {
            return; // Nothing to do
        }

        // Take the minimum of batch size and remaining rows to avoid over-fetching
        Integer fetchSize = Math.min(200, remainingRows);

        List<Contact> scope = locator.fetch(position, 200);
        position += scope.size();
        // do something, like archive or delete the scope list records
        if (position < locator.getNumRecords()) {
            // process the next chunk
            System.enqueueJob(this);
        }
    }
}