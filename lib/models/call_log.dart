class CallLog {
  const CallLog({
    required this.logId,
    required this.tableId,
    required this.sessionId,
    required this.type,
    required this.status,
  });

  final String logId;
  final String tableId;
  final String sessionId;
  final String type;
  final String status;

  factory CallLog.fromJson(Map<String, dynamic> json) => CallLog(
    logId: '${json['LogID'] ?? ''}',
    tableId: '${json['TableID'] ?? ''}',
    sessionId: '${json['SessionID'] ?? ''}',
    type: '${json['Type'] ?? ''}',
    status: '${json['Status'] ?? ''}',
  );

  Map<String, dynamic> toJson() => {
    'LogID': logId,
    'TableID': tableId,
    'SessionID': sessionId,
    'Type': type,
    'Status': status,
  };
}
