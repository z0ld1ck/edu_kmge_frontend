class ImportedAccount {
  final String email;
  final String fullName;
  final String password;
  const ImportedAccount(
      {required this.email, required this.fullName, required this.password});

  factory ImportedAccount.fromJson(Map<String, dynamic> j) => ImportedAccount(
    email: (j['email'] ?? '').toString(),
    fullName: (j['full_name'] ?? '').toString(),
    password: (j['password'] ?? '').toString(),
  );
}

class ImportIssue {
  final int row;
  final String email;
  final String reason;
  const ImportIssue(
      {required this.row, required this.email, required this.reason});

  factory ImportIssue.fromJson(Map<String, dynamic> j) => ImportIssue(
    row: (j['row'] ?? 0) as int,
    email: (j['email'] ?? '').toString(),
    reason: (j['reason'] ?? '').toString(),
  );
}

class UserImportResult {
  final int created;
  final int skipped;
  final List<ImportedAccount> accounts;
  final List<ImportIssue> issues;
  const UserImportResult({
    required this.created,
    required this.skipped,
    required this.accounts,
    required this.issues,
  });

  factory UserImportResult.fromJson(Map<String, dynamic> j) => UserImportResult(
    created: (j['created'] ?? 0) as int,
    skipped: (j['skipped'] ?? 0) as int,
    accounts: ((j['accounts'] ?? const []) as List)
        .map((e) => ImportedAccount.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    issues: ((j['issues'] ?? const []) as List)
        .map((e) => ImportIssue.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
  );
}