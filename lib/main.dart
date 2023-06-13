import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51K4LOsIsvUnLlgte15bN5NEiKNtySPbkeg2i921HVEZAuA81OsZuvjnKqO55N30BqeZ48Jy4BhCC25LU9TET9pA500SWljWJw0";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSaving = false;
  TextEditingController _textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CardField(
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(hintText: 'Card Holder Name'),
                validator: (value) => value!.isEmpty ? "Error" : null,
              ),
              Spacer(),
              ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()){
                      return;
                    }
                    setState(() {
                      isSaving = true;
                    });
                    // Uncomment this to use compute
                    //  await compute(speedUpAddCard, [Stripe.instance, _textEditingController.text!])

                    await Stripe.instance
                        .createPaymentMethod(
                            params: PaymentMethodParams.card(
                              paymentMethodData: PaymentMethodData(
                                billingDetails: BillingDetails(
                                    name: _textEditingController.text),
                              ),
                            ),
                            options: const PaymentMethodOptions(
                                setupFutureUsage:
                                    PaymentIntentsFutureUsage.OnSession))
                        .then((value) async {
                          log('Payment Method Created');
                      await Stripe.instance
                          .createToken(const CreateTokenParams.card(
                              params: CardTokenParams(
                        type: TokenType.Card,
                      )))
                          .then((value) async {
                            print(value);
                        log('Token Created');

                        // Call API to save Token at server
                      });
                    });
                    setState(() {
                      isSaving = false;
                    });
                  },
                  child: isSaving
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text('Save Card'))
            ],
          ),
        ),
      ),
    );
  }
}

/// This function is created for compute
Future<PaymentMethod> speedUpAddCard(List<dynamic> params) {
  // Stripe.publishableKey =
  // "pk_test_51K4LOsIsvUnLlgte15bN5NEiKNtySPbkeg2i921HVEZAuA81OsZuvjnKqO55N30BqeZ48Jy4BhCC25LU9TET9pA500SWljWJw0";

  return params[0].createPaymentMethod(
      params: PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: BillingDetails(name: params[1]), // it didn't work
        ),
      ),
      options: const PaymentMethodOptions(
          setupFutureUsage: PaymentIntentsFutureUsage.OnSession));
}
