/// Represents the synchronization status of a record.
enum SyncStatus {
  /// The record has not been synced yet.
  pending,
  
  /// The record is currently being synced.
  syncing,
  
  /// The record has been successfully synced.
  synced,
  
  /// There was an error during synchronization.
  error,
  
  /// The record has been marked for deletion and needs to be synced.
  pendingDeletion,
  
  /// The record has been deleted on the server.
  deleted,
}
