import 'dart:convert';

import 'package:annora_survey/models/wo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WOViewModel {
  Future<Map<String, dynamic>> getWO(String woID) async {
    final String woUrl = dotenv.env['GET_WO_PROJECT_URL'] ?? '';
    if (woUrl.isEmpty) {
      return {'success': false, 'message': 'API URL is not available'};
    }
    try {
      final response = await http.post(
        Uri.parse(woUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'wo_id': woID},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Success') {
          final woData = data['data'];
          WO wo = WO(
            id: int.tryParse(woData['id']?.toString() ?? '0') ?? 0,
            createdAt: DateTime.parse(woData['created_at']),
            clientID: woData['client_id'],
            appNo: woData['app_no'],
            customerName: woData['customer_name'],
            cabang: woData['cabang'],
            unit: woData['unit'],
            statusUnit: woData['status_unit'],
            alamat: woData['alamat'],
            telephone: woData['telephone'],
            namaPerusahaan: woData['nama_perusahaan'],
            jabatan: woData['jabatan'],
            sales: woData['sales'],
            keterangan: woData['keterangan'],
            kodePos: woData['kode_pos'],
            jenisSurvey: woData['jenis_survey'],
            tipeSurvey: woData['tipe_survey'],
            namaPasangan: woData['nama_pasangan'],
            status: woData['status'],
          );
          return {'success': true, 'data': wo};
        } else {
          return {
            'success': false,
            'message': 'API response message: ${data['message']}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Fetching tasks failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
