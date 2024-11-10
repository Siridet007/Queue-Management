class GetQueue {
  String? nextqueue;
  String? qdate;
  String? queuewait;

  GetQueue({this.nextqueue, this.qdate, this.queuewait});

  GetQueue.fromJson(Map<String, dynamic> json) {
    nextqueue = json['nextqueue'];
    qdate = json['qdate'];
    queuewait = json['queuewait'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nextqueue'] = nextqueue;
    data['qdate'] = qdate;
    data['queuewait'] = queuewait;
    return data;
  }
  static List<GetQueue>? fromJsonList(List list) {
    //if (list == null) return null;
    return list.map((item) => GetQueue.fromJson(item)).toList();
  }
}
