import 'dart:async';

class RefreshService {
  static final RefreshService _instance = RefreshService._internal();
  final _refreshController = StreamController<bool>.broadcast();

  factory RefreshService() => _instance;

  RefreshService._internal();

  Stream<bool> get refreshStream => _refreshController.stream;

  void notifyRefresh() {
    _refreshController.add(true);
  }

  void dispose() {
    _refreshController.close();
  }
}
