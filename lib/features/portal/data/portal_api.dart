import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/api_response.dart';
import '../../../core/network/providers.dart';
import 'models/contact_model.dart';

final portalApiProvider = Provider<PortalApi>((ref) {
  final api = ref.watch(apiClientProvider);
  return PortalApi(api);
});

class PortalApi {
  const PortalApi(this._api);

  final ApiClient _api;

  Future<List<ContactModel>> contacts() async {
    return _api.getJsonList(
      '/contacts',
      fromJson: ContactModel.fromJson,
    );
  }

  Future<ApiResponse<List<ContactModel>>> contactsPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    final json = await _api.getJson<Object?>('/contacts', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    if (json is Map<String, dynamic>) {
      final data = json['data'] as List? ?? [];
      return ApiResponse<List<ContactModel>>(
        data: data
            .whereType<Map>()
            .map((e) => ContactModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        message: json['message'] as String?,
        success: json['success'] as bool? ?? true,
      );
    }
    return ApiResponse<List<ContactModel>>(data: const [], success: true);
  }
}

