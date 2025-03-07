import 'package:alippepro_v1/profile-new/widgets/files.dart';
import 'package:alippepro_v1/profile-new/widgets/folder_shape.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Менин папкаларым',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FileViewerScreen()));
              },
              child: const Column(
                children: [
                  FolderShape(),
                  Gap(10),
                  Text(
                    'Сабактын пландары',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                  )
                ],
              ),
            ),
          ]),
        ),
        // Row(
        //   children: [
        //     InkWell(
        //       onTap: () {
        //         showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             return AlertDialog(
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(20),
        //               ),
        //               content: SizedBox(
        //                 width: 200,
        //                 height: 91,
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     const SizedBox(
        //                       width: 150,
        //                       height: 20,
        //                       child: TextField(
        //                         decoration: InputDecoration(
        //                           hintText: 'Папканын аталышы',
        //                           hintStyle: TextStyle(
        //                               fontSize: 12,
        //                               fontWeight: FontWeight.w300),
        //                           enabledBorder: OutlineInputBorder(
        //                             borderSide: BorderSide(color: Colors.black),
        //                           ),
        //                           focusedBorder: OutlineInputBorder(
        //                             borderSide: BorderSide(color: Colors.black),
        //                           ),
        //                           border: OutlineInputBorder(),
        //                         ),
        //                       ),
        //                     ),
        //                     const Gap(20),
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.center,
        //                       children: [
        //                         CustomButton(
        //                           text: "Артка",
        //                           onTap: () {
        //                             Navigator.pop(context);
        //                           },
        //                           color: Colors.white,
        //                           textColor: Colors.black,
        //                         ),
        //                         const Gap(10),
        //                         CustomButton(
        //                           text: "Создать",
        //                           onTap: () {
        //                             Navigator.pop(context);
        //                           },
        //                           color: Colors.black,
        //                           textColor: Colors.white,
        //                         ),
        //                       ],
        //                     )
        //                   ],
        //                 ),
        //               ),
        //             );
        //           },
        //         );
        //       },
        //       child: const AppIcon(
        //         AppIcons.add,
        //         size: 40,
        //       ),
        //     ),
        //     const Gap(45),

        //   ],
        // ),
        // const Spacer(),
        // InkWell(
        //     onTap: () {
        //       showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return AlertDialog(
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(20),
        //             ),
        //             content: SizedBox(
        //               width: 200,
        //               height: 160,
        //               child: Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //                   const SizedBox(
        //                       width: 150,
        //                       height: 20,
        //                       child: Text(
        //                         'Папаканы өчүрүүнү каалайсызбы?',
        //                         style: TextStyle(
        //                             fontSize: 12,
        //                             fontWeight: FontWeight.w300,
        //                             color: Colors.red),
        //                       )),
        //                   const Gap(20),
        //                   Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       CustomButton(
        //                         text: "Артка",
        //                         onTap: () {
        //                           Navigator.pop(context);
        //                         },
        //                         color: Colors.white,
        //                         textColor: Colors.black,
        //                       ),
        //                       const Gap(10),
        //                       CustomButton(
        //                         text: "Өчүрүү",
        //                         onTap: () {
        //                           Navigator.pop(context);
        //                         },
        //                         color: Colors.red,
        //                         textColor: Colors.white,
        //                       ),
        //                     ],
        //                   )
        //                 ],
        //               ),
        //             ),
        //           );
        //         },
        //       );
        //     },
        //     child: const AppIcon(AppIcons.trash, size: 30)),
        // const Gap(50),
      ],
    );
  }
}
