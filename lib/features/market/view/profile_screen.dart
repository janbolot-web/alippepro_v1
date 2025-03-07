import 'dart:convert';

import 'package:alippepro_v1/features/market/widgets/%D1%81reate-porduct_screen.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alippepro_v1/features/market/widgets/create_store.dart';
import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:alippepro_v1/features/market/widgets/store_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _stores = [];
  bool _isLoading = false;
  var userData;

  @override
  void initState() {
    super.initState();
    _fetchStores();
    // streamGptPrompt();
    getUserData();
  }

  getUserData() async {
    var user = await getDataFromLocalStorage('user');
    userData = jsonDecode(user!);
  }

  Future<void> _fetchStores() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var stores = await APIService.getStores();
      setState(() {
        _stores = stores;
      });
    } catch (e) {
      setState(() {
        _stores = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshPage() {
    _fetchStores();
  }

  @override
  Widget build(BuildContext context) {
    return userData?['roles']?[0].toString() == "ADMIN"
        ? Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
            appBar: AppBar(
              title: Text(
                'Профиль',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1B434D),
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      // Implement store search functionality if needed
                    },
                    decoration: InputDecoration(
                      hintText: 'Поиск магазина...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),

                // Store list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _fetchStores,
                          child: _stores.isNotEmpty
                              ? ListView.builder(
                                  itemCount: _stores.length,
                                  itemBuilder: (context, index) {
                                    return StoreItem(
                                      store: _stores[index],
                                      onEdit: () {
                                        // Реализация редактирования
                                      },
                                      onDelete: () async {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              title: const Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.red),
                                                  SizedBox(width: 8.0),
                                                  Text(
                                                    'Удаление магазина',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              content: const Text(
                                                'Вы уверены, что хотите удалить этот магазин? Это действие нельзя отменить.',
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Colors.black87),
                                              ),
                                              actionsPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        false); // Не удалять
                                                  },
                                                  child: const Text(
                                                    'Отмена',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        true); // Подтвердить удаление
                                                  },
                                                  child: const Text(
                                                    'Удалить',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (shouldDelete == true) {
                                          try {
                                            await APIService.deleteStore(
                                                _stores[index]['_id']);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Магазин успешно удалён'),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                            );
                                            _fetchStores(); // Обновить список после удаления
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Не удалось удалить магазин'),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      onAddProduct: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CreateProductScreen(
                                                    storeId: _stores[index]
                                                        ['_id']),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : ListView(
                                  children: [
                                    Center(
                                      child: Text(
                                        'Магазины не найдены',
                                        style: GoogleFonts.rubik(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                ),
                // Fixed "Create Store" button at the bottom
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Navigate to CreateShopScreen and refresh after returning
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateShopScreen(),
                          ),
                        );
                        _refreshPage();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 5,
                      ),
                      child: Text(
                        "Добавить новый магазин",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                'Профиль',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1B434D),
                ),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: const Center());
  }
}
