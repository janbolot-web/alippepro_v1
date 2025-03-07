import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360.0,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Тиркеменин автору',
                        style: GoogleFonts.montserrat(
                            fontSize: 10, color: const Color(0xff1B434D)),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        'Тынчтыкбек Кенжебек уулу',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: const Color(0xff1B434D),
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  )),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xffAC046A),
                          Color(0xff005D67),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          border: Border.all(
                              width: 3,
                              color: Colors.white,
                              style: BorderStyle.solid)),
                      child: const CircleAvatar(
                        radius: 120,
                        backgroundImage: AssetImage(
                          'assets/img/tynchtyk.jpg',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 80.0, vertical: 20),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: Color(0xff1B434D)),
                      children: [
                        // "Alippe pro" — жирным
                        TextSpan(
                          text: '“Alippe pro”',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' мугалимдерди өнүктүрүүчү аянтчасынын жана ',
                        ),
                        // "Evrika" — жирным
                        TextSpan(
                          text: '“Evrika”',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' окуу борборунун негиздөөчүсү.\n\n\n  ',
                        ),
                        TextSpan(
                          text: 'Максат',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),TextSpan(
                          text: '- мугалимдин түйшүгүн жеңилдетип, ишмердүүлүгүнүн сапатын жакшыртуу.  ',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50,),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          //   child: Text(
                          //     'Ээси тууралуу маалымат',
                          //     style: GoogleFonts.montserrat(
                          //         fontSize: 16,
                          //         fontWeight: FontWeight.w900,
                          //         color: const Color(0xff1B434D)),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),

                          const SizedBox(height: 16),
                          _buildInfoRow('Компаниянын аталышы: ', 'Эврика плюс'),
                          _buildInfoRow('Юридикалык адрес:  ',
                              'г. Бишкек, ул. Ахунбаева 172'),
                          _buildInfoRow('ИНН / ОГРН:  ', '01701202410393'),
                          const SizedBox(height: 14),
                          _buildSectionTitle(context, 'Байланышуу'),
                          const SizedBox(height: 10),
                          // _buildInfoRow('Телефон: ', '0707 19 42 14'),
                          _buildInfoRow('Email: ', 'alippepro@alippepro.net'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xff1B434D)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 8,
                  color: const Color(0xff1B434D),
                  fontWeight: FontWeight.w400)),
          Expanded(
            child: Text(value,
                overflow: TextOverflow.clip, // Обрезка текста, если нужно
                softWrap: true,
                style: GoogleFonts.montserrat(
                    fontSize: 8,
                    color: const Color(0xff1B434D),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
