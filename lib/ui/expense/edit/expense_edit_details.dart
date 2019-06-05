import 'package:flutter/material.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/ui/app/entity_dropdown.dart';
import 'package:invoiceninja_flutter/ui/app/forms/custom_field.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_vm.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/redux/static/static_selectors.dart';

class ExpenseEditDetails extends StatefulWidget {
  const ExpenseEditDetails({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final ExpenseEditVM viewModel;

  @override
  ExpenseEditDetailsState createState() => ExpenseEditDetailsState();
}

class ExpenseEditDetailsState extends State<ExpenseEditDetails> {
  final _custom1Controller = TextEditingController();
  final _custom2Controller = TextEditingController();

  final List<TextEditingController> _controllers = [];

  @override
  void didChangeDependencies() {
    final List<TextEditingController> _controllers = [
      _custom1Controller,
      _custom2Controller,
    ];

    _controllers
        .forEach((dynamic controller) => controller.removeListener(_onChanged));

    final expense = widget.viewModel.expense;
    _custom1Controller.text = expense.customValue1;
    _custom2Controller.text = expense.customValue2;

    _controllers
        .forEach((dynamic controller) => controller.addListener(_onChanged));

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controllers.forEach((dynamic controller) {
      controller.removeListener(_onChanged);
      controller.dispose();
    });

    super.dispose();
  }

  void _onChanged() {
    final viewModel = widget.viewModel;
    final expense = viewModel.expense.rebuild((b) => b
      ..customValue1 = _custom1Controller.text.trim()
      ..customValue2 = _custom2Controller.text.trim());
    if (expense != viewModel.expense) {
      viewModel.onChanged(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final company = viewModel.company;
    final staticState = viewModel.state.staticState;

    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        FormCard(
          children: <Widget>[
            EntityDropdown(
              entityType: EntityType.currency,
              entityMap: staticState.currencyMap,
              entityList: memoizedCurrencyList(staticState.currencyMap),
              labelText: localization.currency,
              initialValue:
              staticState.currencyMap[viewModel.expense.expenseCurrencyId]?.name,
              onSelected: (SelectableEntity currency) => viewModel.onChanged(
                  viewModel.expense.rebuild((b) => b..expenseCurrencyId = currency.id)),
            ),
            CustomField(
              controller: _custom1Controller,
              labelText: company.getCustomFieldLabel(CustomFieldType.expense1),
              options: company.getCustomFieldValues(CustomFieldType.expense1),
            ),
            CustomField(
              controller: _custom2Controller,
              labelText: company.getCustomFieldLabel(CustomFieldType.expense2),
              options: company.getCustomFieldValues(CustomFieldType.expense2),
            ),
          ],
        ),
      ],
    );
  }
}
