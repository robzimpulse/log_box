enum DatabaseOperation {
  beginTransaction('Begin Transaction'),
  commitTransaction('Commit Transaction'),
  rollbackTransaction('Rollback Transaction'),
  runBatched('Batched'),
  runCustom('Custom'),
  runDelete('Delete'),
  runInsert('Insert'),
  runSelect('Select'),
  runUpdate('Update');

  final String rawValue;

  const DatabaseOperation(this.rawValue);
}