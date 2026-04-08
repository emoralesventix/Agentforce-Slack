public class CursorQueueable implements Queueable {
    private static final Integer CHUNK_SIZE = 200;

    public void execute(QueueableContext ctx) {
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id FROM Account ORDER BY Id',
            AccessLevel.USER_MODE
        );

        Integer totalRows = cursor.getNumRecords();
        Integer position = 0;

        while (position < totalRows) {
            Integer remainingRows = totalRows - position;
            Integer fetchSize = Math.min(CHUNK_SIZE, remainingRows);
            List<Account> chunk = cursor.fetch(position, fetchSize);
            Integer chunkSize = chunk == null ? 0 : chunk.size();
            if (chunkSize == 0) break;
            position += chunkSize;
        }
    }
}