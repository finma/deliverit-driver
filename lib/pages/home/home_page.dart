import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/cubit/navigation_cubit.dart';
import '/config/app_color.dart';
import '/pages/home/chat_page.dart';
import '/pages/home/history_page.dart';
import '/pages/home/home_screen.dart';
import '/pages/home/wallet_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> screens = [
    const HomeScreen(),
    const WalletPage(),
    const HistoryPage(),
    const ChatPage(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: BlocBuilder<NavigationCubit, int>(
          builder: (context, indexPage) {
            return screens[indexPage];
          },
        ),
      ),
      bottomNavigationBar: const BottomAppBarWidget(),
    );
  }
}

class BottomAppBarWidget extends StatelessWidget {
  const BottomAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 60,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // * LEFT TAB BAR ICONS
            NavigationButton(
              icon: Icons.home_rounded,
              title: 'Beranda',
              tabIndex: 0,
            ),
            NavigationButton(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Wallet',
              tabIndex: 1,
            ),
            // * RIGHT TAB BAR ICONS
            NavigationButton(
              icon: Icons.history_rounded,
              title: 'History',
              tabIndex: 2,
            ),
            NavigationButton(
              icon: Icons.chat_rounded,
              title: 'Chat',
              tabIndex: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final int tabIndex;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.title,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        context.read<NavigationCubit>().setTabIndex(tabIndex);
      },
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, indexPage) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: indexPage == tabIndex ? AppColor.primary : Colors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: indexPage == tabIndex ? AppColor.primary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
