import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cash_register/presentation/cubit/cash_register_cubit.dart';
import '../../../cash_register/presentation/cubit/cash_register_state.dart';
import '../../../cash_register/presentation/views/open_cash_session_view.dart';
import '../cubit/cart_cubit.dart';
import '../views/sale_view.dart';

/// Ventas tab. With the drawer closed it asks to open it; once open it shows
/// the cart, which is the whole point-of-sale screen.
class SalesTabScreen extends StatefulWidget {
  const SalesTabScreen({
    required this.onOpenCatalog,
    required this.onCheckout,
    required this.onManageCashRegister,
    super.key,
  });

  final void Function({String? categoryId}) onOpenCatalog;
  final VoidCallback onCheckout;
  final VoidCallback onManageCashRegister;

  @override
  State<SalesTabScreen> createState() => _SalesTabScreenState();
}

class _SalesTabScreenState extends State<SalesTabScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CashRegisterCubit>().load();
    context.read<CartCubit>().loadSaleNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CashRegisterCubit, CashRegisterState>(
        builder: (BuildContext context, CashRegisterState state) {
          if (state.status == CashRegisterStatus.initial ||
              (state.status == CashRegisterStatus.loading &&
                  state.session == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.isOpen) return const OpenCashSessionView();

          return SaleView(
            onOpenCatalog: widget.onOpenCatalog,
            onCheckout: widget.onCheckout,
            onManageCashRegister: widget.onManageCashRegister,
          );
        },
      ),
    );
  }
}
