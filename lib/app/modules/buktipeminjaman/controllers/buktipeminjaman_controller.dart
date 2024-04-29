import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/constant/endpoint.dart';
import '../../../data/model/peminjaman/response_detail_peminjaman.dart';
import '../../../data/provider/api_provider.dart';
import '../../../routes/app_pages.dart';

class BuktipeminjamanController extends GetxController with StateMixin{

  // Get Data
  var detailPeminjaman = Rxn<DetailPeminjaman>();

  final idPeminjaman = Get.parameters['idPeminjaman'].toString();

  var loadingPinjam = false.obs;

  @override
  void onInit() {
    super.onInit();
    getDataDetailPeminjaman(idPeminjaman);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getDataDetailPeminjaman(String? idPinjam) async {
    detailPeminjaman.value == null;
    change(null, status: RxStatus.loading());

    try {
      final responseDetailBuku = await ApiProvider.instance().get(
          '${Endpoint.detailPeminjaman}/$idPinjam');

      if (responseDetailBuku.statusCode == 200) {
        final ResponseDetailPeminjaman responseDetailPeminjaman = ResponseDetailPeminjaman.fromJson(responseDetailBuku.data);

        if (responseDetailPeminjaman.data == null) {
          detailPeminjaman.value == null;
          change(null, status: RxStatus.empty());
        } else {
          detailPeminjaman(responseDetailPeminjaman.data);
          change(null, status: RxStatus.success());
        }
      } else {
        change(null, status: RxStatus.error("Gagal Memanggil Data"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData != null) {
          final errorMessage = responseData['message'] ?? "Unknown error";
          change(null, status: RxStatus.error(errorMessage));
        }
      } else {
        change(null, status: RxStatus.error(e.message));
      }
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  updatePeminjaman(String peminjamanID, String asal) async {
    loadingPinjam(true);
    try {
      FocusScope.of(Get.context!).unfocus();

      var response = await ApiProvider.instance()
          .patch('${Endpoint.updatePeminjaman}$peminjamanID');

      if (response.statusCode == 200) {
        _showMyDialog(
              () {
            Get.offAllNamed(Routes.DASHBOARD);
          },
          "Berhasil",
          "Peminjaman buku berhasil dikembalikan",
          "Oke",
        );
      } else {
        _showMyDialog(
              () {
            Navigator.pop(Get.context!, 'OK');
          },
          "Pemberitahuan",
          "Buku gagal dikembalikan, silakan coba kembali",
          "Ok",
        );
      }
      loadingPinjam(false);
    } on DioException catch (e) {
      loadingPinjam(false);
      if (e.response != null) {
        if (e.response?.data != null) {}
      } else {
        _showMyDialog(
              () {
            Navigator.pop(Get.context!, 'OK');
          },
          "Pemberitahuan",
          e.message ?? "",
          "OK",
        );
      }
    } catch (e) {
      loadingPinjam(false);
      _showMyDialog(
            () {
          Navigator.pop(Get.context!, 'OK');
        },
        "Error",
        e.toString(),
        "OK",
      );
    }
  }


  Future<void> _showMyDialog(final onPressed, String judul, String deskripsi, String nameButton) async {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: Text(
            'Flowbook App',
            style: GoogleFonts.averiaGruesaLibre(
              fontWeight: FontWeight.w900,
              fontSize: 20.0,
              color: const Color(0xFF56526F),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  judul,
                  style: GoogleFonts.averiaGruesaLibre(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 18.0
                  ),
                ),
                Text(
                  deskripsi,
                  style: GoogleFonts.averiaGruesaLibre(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 18.0
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                animationDuration: const Duration(milliseconds: 300),
              ),
              onPressed: onPressed,
              child: Text(
                nameButton,
                style: GoogleFonts.averiaGruesaLibre(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF008A93),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
