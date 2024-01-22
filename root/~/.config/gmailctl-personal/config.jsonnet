// vim: set shiftwidth=2
// IMPORTANT: use the `gmailctlp edit` command to modify this file!
local lib = import 'gmailctl.libsonnet';
local me = "kevin.j.carruthers@gmail.com";

local delete(read=true) = {
  delete: true,
  markImportant: false,
  markRead: read,
};
local label(label, archive=true, read=false) = {
  archive: archive,
  labels: [ label ],
  markImportant: false,
  markRead: read,
  markSpam: false,
};

local rules = [
  {
    filter: {
      or: [
        { from: "Chase QuickPay Team" },
        { from: "CustomerServiceOnline@billpay.pge.com" },
        { from: "billing@mailgun.net" },
        { from: "ebill@conservicemail.com" },
        { from: "faturacao.eletronica@galp.com" },
        { from: "googlepay-noreply@google.com" },
        { from: "payments-noreply@google.com" },
        { from: "receipts-portugal@bolt.eu" },
        { from: "renewals@namecheap.com" },
        { from: "support@namecheap.com" },
        { from: "uber.us@uber.com" },
        { and: [
          { from: "ActivoBank.Informa@activobank.pt" },
          { or: [
            { subject: "Documentos em formato digital" },
            { subject: "Extrato Combinado" },
          ]},
        ]},
        { and: [
          { from: "alert@eqbank.ca" },
          { subject: "EQ Bank: EFT withdrawal" },
        ]},
        { and: [
          { from: "apoiocliente@vodafone.pt" },
          { subject: "Faturação Vodafone" },
        ]},
        { and: [
          { from: "banco@millenniumbcp.pt" },
          { or: [
            { subject: "Documentos em formato digital" },
            { subject: "Extrato Combinado" },
          ]},
        ]},
        { and: [
          { from: "customercare@remitbee.com" },
          { or: [
            { subject: "Remitbee - Transaction Completed Successfully" },
            { subject: "Remitbee - funds were deposited into your Wallet" },
          ]},
        ]},
        { and: [
          { from: "endesa.pt@cgi.com" },
          { subject: "Documento de Pagamento Eletrónico" },
        ]},
        { and: [
          { from: "facturaelectronica@pingodoce.pt" },
          { subject: "Fatura Eletrónica Pingo Doce" },
        ]},
        { and: [
          { from: "hello@1password.com" },
          { subject: "Your 1Password invoice" },
        ]},
        { and: [
          { from: "help@accts.epicgames.com" },
          { subject: "Your Epic Games Receipt" },
        ]},
        { and: [
          { from: "no-reply@glovoapp.com" },
          { or: [
            { subject: "Details of your glovo" },
            { subject: "Details of your order" },
            { subject: "Glovo Confirmation" },
          ]},
        ]},
        { and: [
          { from: "noreply@steampowered.com" },
          { subject: "Thank you for your Steam purchase!" },
        ]},
        { and: [
          { from: "notify@payments.interac.ca" },
          { subject: "INTERAC e-Transfer: Your money transfer to REMITBEE INCORPORATED was deposited." },
        ]},
        { and: [
          { from: "online.communications@alerts.comcast.net" },
          { subject: "Your bill is ready" },
        ]},
        { and: [
          { from: "service@paypal.com" },
          { subject: "Receipt for Your Payment" },
        ]},
        { and: [
          { from: "social@brimfinancial.com" },
          { or: [
            { subject: "Your foreign purchase was successful" },
            { subject: "Your Payment Was Received" },
          ]},
        ]},
        { and: [
          { from: "support@wealthsimple.com" },
          { subject: "You made a deposit" },
        ]},
        { and: [
          { from: "transaction@remitbee.com" },
          { or: [
            { subject: "Action Required: Transaction pending due to documents" },
            { subject: "Remitbee Transaction Receipt" },
          ]},
        ]},
      ],
    },
    actions: label("Cash/Bills"),
  },
  {
    filter: {
      or: [
        { from: "noreply@robinhood.com" },
        { from: "notifications@robinhood.com" },
        { and: [
          { from: "support@wealthsimple.com" },
          { or: [
            { subject: "You earned a dividend" },
            { subject: "You're staking more" },
            { subject: "Your order has been filled" },
          ]},
        ]},
      ],
    },
    actions: label("Cash/Invest"),
  },
  {
    filter: {
      and: [
        { or: [
          { from: "no-reply@em.wealthfront.com" },
          { from: "support@wealthfront.com" },
        ]},
        { subject: "Investment prospectus" },
      ],
    },
    actions: label("News"),
  },
  {
    filter: {
      or: [
        { from: "bot@fanfiction.com" },
        { from: "bot@fictionpress.com" },
      ],
    },
    actions: label("RSS"),
  },
  {
    filter: {
      or: [
        { from: "noreply@haveibeenpwned.com" },
        { and: [
          { from: "no-reply@accounts.google.com" },
          { subject: "Security alert" },
        ]},
      ],
    },
    actions: label("Security", archive=false),
  },
  {
    filter: {
      or: [
        { and: [
          { from: "ibanking@ib.rbc.com" },
          { subject: "Your RBC Royal Bank eStatement is ready" },
        ]},
        { and: [
          { from: "info@mail.coinbase.com" },
          { subject: "Coinbase statement is ready to download" },
        ]},
        { and: [
          { from: "no-reply@alertsp.chase.com" },
          { subject: "Your statement is ready for account" },
        ]},
        { and: [
          { from: "no-reply@em.wealthfront.com" },
          { or: [
            { subject: "Your monthly Cash Account statement from Green Dot Bank is available" },
            { subject: "Your Monthly Wealthfront Brokerage Statement" },
          ]},
        ]},
        { and: [
          { from: "no-reply@revolut.com" },
          { subject: "View your documents" },
        ]},
        { and: [
          { from: "notifications@m.wealthsimple.com" },
          { subject: "statement is available" },
        ]},
        { and: [
          { from: "PayPal@emails.paypal.com" },
          { subject: "account statement is available." },
        ]},
        { and: [
          { from: "social@brimfinancial.com" },
          { subject: "Your statement is ready" },
        ]},
        { and: [
          { from: "venmo@venmo.com" },
          { subject: "Venmo Quarterly Statement" },
        ]},
      ],
    },
    actions: delete(),
  },
];

local labels = [
  { name: "Cash" },
  { name: "Cash/Bills" },
  { name: "Cash/Giftcards" },
  { name: "Cash/Invest" },
  { name: "Cash/Stock" },
  { name: "Dev" },
  { name: "Family" },
  { name: "Jobs" },
  { name: "News" },
  { name: "RSS" },
  { name: "Records" },
  { name: "Security" },
];

{
  version: "v1alpha3",
  author: {
    name: "Kevin James",
    email: me,
  },
  labels: labels,
  rules: rules,
}
