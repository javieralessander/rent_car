import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/preferences.dart';
import '../../auth/screens/auth_gate.dart';
import '../../auth/services/auth_service.dart';
import '../services/user_profile_service.dart';

class UserProfileScreen extends StatelessWidget {
  static const String name = 'user-profile';

  final double coverHeight = 280;
  final double profileHeight = 144;

  const UserProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final top = (coverHeight - profileHeight / 2) - 60;
    final sizeScreen = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    List<ToolOption> opciones = [
      ToolOption(
        icon: CupertinoIcons.bell,
        title: 'Configurar Notificaciones',
        route: null,
      ),
      ToolOption(
        icon: CupertinoIcons.shield,
        title: 'Inicio de sesión rápida',
        description: 'Ingrese con su Face ID o huella dactilar',
        route: null,
      ),
      ToolOption(
        icon: CupertinoIcons.info,
        title: 'Información de productos',
        description: 'Ver detalles de productos, políticas y contratos',
        route: null,
      ),
      ToolOption(
        icon: CupertinoIcons.question_circle,
        title: 'Soporte',
        description: 'Ayuda y soporte a usuarios',
        route: null,
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0, // Sin sombra
        leading: IconButton(
          color: Colors.transparent,
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.white : AppColors.dark,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          buildTop(context, top, sizeScreen),
          SizedBox(height: sizeScreen.height * 0.20),

          // Tools options list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sizeScreen.width * 0.05),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: opciones.length,
              padding: EdgeInsets.zero,
              itemBuilder:
                  (context, index) => ListTile(
                    dense: true,
                    leading: Icon(opciones[index].icon),
                    isThreeLine:
                        opciones[index].description != null ? true : false,
                    title: Text(opciones[index].title!),
                    contentPadding: EdgeInsets.zero,
                    subtitle:
                        opciones[index].description != null
                            ? Text(opciones[index].description!)
                            : null,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      if (opciones[index].route != null) {
                        context.pushNamed(opciones[index].route!);
                      }
                    },
                  ),
              separatorBuilder:
                  (context, index) => const Divider(height: 0, thickness: 1.5),
            ),
          ),

          // Tools options list end
          SizedBox(height: sizeScreen.height * 0.05),

          // Logout button
          // Logout button
          Center(
            child: TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Confirmación'),
                        content: const Text(
                          '¿Seguro que deseas cerrar la sesión?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  final authService = context.read<AuthService>();
                  await authService.logout();
                  if (!context.mounted) return;

                  context.pushReplacementNamed(AuthGate.name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada exitosamente'),
                    ),
                  );
                }
              },
              child: Text(
                'Cerrar Sesión',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTop(BuildContext context, double top, Size size) {
    final bottom = profileHeight * 0.2;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: bottom),
            child: buildCoverImage(),
          ),
          Positioned(
            top: top,
            child: Center(
              child: Container(
                height: size.width / 2 + profileHeight - 80,
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: cardBio(context, size),
              ),
            ),
          ),
          Positioned(
            top: (top / 2) + (profileHeight * 0.14),
            child: buildProfileImage(),
          ),
        ],
      ),
    );
  }

  Widget buildCoverImage() => ClipPath(
    clipper: DiagonalClipper(),
    child: Image.asset(
      'assets/images/tiendafisica.jpg',
      alignment:
          AlignmentGeometry.lerp(
            Alignment.center,
            Alignment.bottomCenter,
            0.7,
          )!,
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );

  Widget buildProfileImage() => Container(
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 0)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: CircleAvatar(
        radius: (profileHeight / 2 - 25),
        child: CircleAvatar(
          radius: profileHeight / 3,
          backgroundColor: Color.fromARGB(
            255,
            Random().nextInt(256),
            Random().nextInt(256),
            Random().nextInt(256),
          ),
          child: Text(
            (Preferences.user.name ?? Preferences.user.email)?.isNotEmpty ==
                    true
                ? (Preferences.user.name ?? Preferences.user.email)![0]
                    .toUpperCase()
                : 'N',
            style: const TextStyle(color: Colors.white, fontSize: 40.0),
          ),
        ),
      ),
    ),
  );

  Widget cardBio(BuildContext context, Size sizeScreen) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: EdgeInsets.all(sizeScreen.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: sizeScreen.height * 0.04),
          Text(
            textAlign: TextAlign.center,
            Preferences.user.name != null
                ? capitalize(Preferences.user.name!.toLowerCase())
                : 'Nombre no registrado',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: sizeScreen.height * 0.018),
            child: Text(
              textAlign: TextAlign.center,
              Preferences.user.email ?? 'Email no registrado',
            ),
          ),

          SizedBox(height: sizeScreen.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final profileService = context.watch<UserProfileService>();
                    await profileService.loadUser();
                  },
                  child: Text('Editar Perfil'),
                ),
              ),
              SizedBox(width: sizeScreen.width * 0.03),
              IconButton.filled(
                iconSize: sizeScreen.width * 0.08,
                onPressed: () async {},
                icon: const Icon(CupertinoIcons.settings),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  String capitalize(String? text) {
    if (text == null || text.isEmpty) {
      return text ?? '';
    }
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  String formatPhoneNumber(String? number) {
    return '(${number!.substring(0, 3)}) ${number.substring(3, 6)}-${number.substring(6)}';
  }
}

Widget toolsOptionsList(Size sizeScreen) {
  List<ToolOption> opciones = [
    ToolOption(
      icon: CupertinoIcons.bell,
      title: 'Configurar Notificaciones',
      route: null,
    ),
    ToolOption(
      icon: CupertinoIcons.shield,
      title: 'Inicio de sesión rápida',
      description: 'Ingrese con su Face ID o huella dactilar',
      route: null,
    ),
    ToolOption(
      icon: CupertinoIcons.info,
      title: 'Información de productos',
      description: 'Ver detalles de productos, políticas y contratos',
      route: null,
    ),
    ToolOption(
      icon: CupertinoIcons.question_circle,
      title: 'Soporte',
      description: 'Ayuda y soporte a usuarios',
      route: null,
    ),
  ];
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: sizeScreen.width * 0.05),
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: opciones.length,
      padding: EdgeInsets.zero,
      itemBuilder:
          (context, index) => ListTile(
            dense: true,
            leading: Icon(opciones[index].icon),
            isThreeLine: opciones[index].description != null ? true : false,
            title: Text(opciones[index].title!),
            contentPadding: EdgeInsets.zero,
            subtitle:
                opciones[index].description != null
                    ? Text(opciones[index].description!)
                    : null,
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              if (opciones[index].route != null) {
                context.pushNamed(opciones[index].route!);
              }
            },
          ),
      separatorBuilder:
          (context, index) => const Divider(height: 0, thickness: 1.5),
    ),
  );
}

class ToolOption {
  final IconData? icon;
  final String? title;
  final String? description;
  final String? route;

  ToolOption({this.icon, this.title, this.description, this.route});
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(0.0, size.height / 1.3);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
