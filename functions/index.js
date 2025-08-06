/**
 * Firebase Functions para integração com M-Pesa (Safaricom Daraja API).
 * @module mpesa
 */
const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");

admin.initializeApp();

// Credenciais M-Pesa (configuradas como variáveis de ambiente)
const CONSUMER_KEY = functions.config().mpesa.consumer_key;
const CONSUMER_SECRET = functions.config().mpesa.consumer_secret;
const SHORTCODE = functions.config().mpesa.shortcode;
const PASSKEY = functions.config().mpesa.passkey;
const BASE_URL = "https://sandbox.safaricom.co.ke"; // Use 'api' para produção

/**
 * Gera um token OAuth para autenticação com a API M-Pesa.
 * @returns {Promise<string>} O token de acesso.
 */
async function getAccessToken() {
    const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`)
        .toString("base64");
    const response = await axios.get(
        `${BASE_URL}/oauth/v1/generate?grant_type=client_credentials`,
        {headers: {Authorization: `Basic ${auth}`}}
    );
    return response.data.access_token;
}

/**
 * Gera uma senha dinâmica para a solicitação STK Push.
 * @returns {Object} Objeto com senha e timestamp.
 */
async function generatePassword() {
    const timestamp = new Date()
        .toISOString()
        .replace(/[-:T.]/g, "")
        .slice(0, 14);
    const password = Buffer.from(`${SHORTCODE}${PASSKEY}${timestamp}`)
        .toString("base64");
    return {password, timestamp};
}

/**
 * Inicia uma solicitação STK Push para pagamento via M-Pesa.
 * @param {Object} data - Dados da solicitação (amount, phoneNumber, userId).
 * @param {Object} context - Contexto da chamada da função.
 * @returns {Promise<Object>} Resposta da API M-Pesa.
 */
exports.initiateSTKPush = functions.https.onCall(async (data, context) => {
    const {amount, phoneNumber, userId} = data;
    const token = await getAccessToken();
    const {password, timestamp} = await generatePassword();

    const payload = {
        BusinessShortCode: SHORTCODE,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: amount,
        PartyA: phoneNumber,
        PartyB: SHORTCODE,
        PhoneNumber: phoneNumber,
        CallBackURL: functions.config().mpesa.callback_url,
        AccountReference: `EmartTopup-${userId}`,
        TransactionDesc: "Wallet Topup",
    };

    try {
        const response = await axios.post(
            `${BASE_URL}/mpesa/stkpush/v1/processrequest`,
            payload,
            {headers: {Authorization: `Bearer ${token}`}}
        );
        return response.data;
    } catch (error) {
        throw new functions.https.HttpsError("internal", error.message);
    }
});

/**
 * Processa o callback da Safaricom para confirmar o pagamento M-Pesa.
 * @param {Object} req - Requisição HTTP com dados do callback.
 * @param {Object} res - Resposta HTTP.
 * @returns {void}
 */
exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
    const callbackData = req.body.Body.stkCallback;
    const resultCode = callbackData.ResultCode;

    if (resultCode === 0) {
        const amount = callbackData.CallbackMetadata.Item.find(
            (item) => item.Name === "Amount"
        ).Value;
        const transactionId = callbackData.CallbackMetadata.Item.find(
            (item) => item.Name === "MpesaReceiptNumber"
        ).Value;
        const userId = callbackData.AccountReference.split("-")[1];

        // Atualizar Firestore
        await admin.firestore().collection("Wallet").add({
            user_id: userId,
            amount: parseFloat(amount),
            payment_method: "M-Pesa",
            payment_id: transactionId,
            date: admin.firestore.FieldValue.serverTimestamp(),
        });
        await admin.firestore().collection("USERS").doc(userId).update({
            walletAmount: admin.firestore.FieldValue.increment(
                parseFloat(amount)
            ),
        });
    }

    res.status(200).send("Callback received");
});
