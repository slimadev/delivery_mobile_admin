import 'package:flutter/material.dart';
import 'package:mpesa_sdk_dart/mpesa_sdk_dart.dart';

class MpesaWithdrawScreen extends StatefulWidget {
  const MpesaWithdrawScreen({Key? key}) : super(key: key);

  @override
  State<MpesaWithdrawScreen> createState() => _MpesaWithdrawScreenState();
}

class _MpesaWithdrawScreenState extends State<MpesaWithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;
  String? _resultMessage;

  // Credenciais de teste fornecidas
  final String apiKey = 'pmptkzyqgg88nny0bsxirn621vzma2z2';
  final String publicKey =
      'MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAmptSWqV7cGUUJJhUBxsMLonux24u+FoTlrb+4Kgc6092JIszmI1QUoMohaDDXSVueXx6IXwYGsjjWY32HGXj1iQhkALXfObJ4DqXn5h6E8y5/xQYNAyd5bpN5Z8r892B6toGzZQVB7qtebH4apDjmvTi5FGZVjVYxalyyQkj4uQbbRQjgCkubSi45Xl4CGtLqZztsKssWz3mcKncgTnq3DHGYYEYiKq0xIj100LGbnvNz20Sgqmw/cH+Bua4GJsWYLEqf/h/yiMgiBbxFxsnwZl0im5vXDlwKPw+QnO2fscDhxZFAwV06bgG0oEoWm9FnjMsfvwm0rUNYFlZ+TOtCEhmhtFp+Tsx9jPCuOd5h2emGdSKD8A6jtwhNa7oQ8RtLEEqwAn44orENa1ibOkxMiiiFpmmJkwgZPOG/zMCjXIrrhDWTDUOZaPx/lEQoInJoE2i43VN/HTGCCw8dKQAwg0jsEXau5ixD0GUothqvuX3B9taoeoFAIvUPEq35YulprMM7ThdKodSHvhnwKG82dCsodRwY428kg2xM/UjiTENog4B6zzZfPhMxFlOSFX4MnrqkAS+8Jamhy1GgoHkEMrsT5+/ofjCx0HjKbT5NuA2V/lmzgJLl3jIERadLzuTYnKGWxVJcGLkWXlEPYLbiaKzbJb2sYxt+Kt5OxQqC1MCAwEAAQ=="';
  final String apiHost = 'https://api.sandbox.vm.co.mz:18352'; // Sandbox
  final String serviceProviderCode =
      '171717'; // Substitua pelo seu código real se necessário

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _resultMessage = null;
    });
    try {
      final token = MpesaConfig.getBearerToken(apiKey, publicKey);
      final payload = PaymentRequest(
        inputTransactionReference:
            'ref${DateTime.now().millisecondsSinceEpoch}',
        inputCustomerMsisdn: _phoneController.text.trim(),
        inputAmount: double.parse(_amountController.text.trim()),
        inputThirdPartyReference: 'ref${DateTime.now().millisecondsSinceEpoch}',
        inputServiceProviderCode: serviceProviderCode,
      );
      final response = await MpesaTransaction.b2c(token, apiHost, payload);
      setState(() {
        _loading = false;
        _resultMessage = 'Saque M-Pesa simulado: ${response.toString()}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _resultMessage = 'Erro ao simular saque M-Pesa: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saque M-Pesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Número de telefone (ex: 25884xxxxxxx):'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o número de telefone';
                  }
                  if (!RegExp(r'^2588[2-7]\d{7}').hasMatch(value)) {
                    return 'Número inválido (deve ser no formato 2588xxxxxxx)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Valor a levantar:'),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor';
                  }
                  final v = double.tryParse(value);
                  if (v == null || v <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Sacar'),
                ),
              ),
              if (_resultMessage != null) ...[
                SizedBox(height: 24),
                Text(_resultMessage!, style: TextStyle(fontSize: 16)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
