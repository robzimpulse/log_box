enum DatabaseOperation {
  beginTransaction('Begin Transaction'),
  commitTransaction('Commit Transaction'),
  rollbackTransaction('Rollback Transaction'),
  runBatched('Batched'),
  runCustom('Custom'),
  runDelete('Delete'),
  runInsert('Insert'),
  runSelect('Select'),
  runUpdate('Update'),
  unknown('Unknown');

  final String rawValue;

  const DatabaseOperation(this.rawValue);

  factory DatabaseOperation.fromRawValue(String value) {
    return DatabaseOperation.values.firstWhere(
      (element) => element.rawValue == value,
      orElse: () => DatabaseOperation.unknown,
    );
  }

  bool get isAtomic {
    return ![beginTransaction, commitTransaction].contains(this);
  }
}
