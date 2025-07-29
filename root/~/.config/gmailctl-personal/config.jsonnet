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
        { and: [
          { from: "hello@1password.com" },
          { subject: "Your 1Password invoice" },
        ]},

        { and: [
          { from: "ActivoBank.Informa@activobank.pt" },
          { or: [
            { subject: "Documentos em formato digital" },
            { subject: "Extrato Combinado" },
          ]},
        ]},

        { from: "receipts-portugal@bolt.eu" },

        { and: [
          { from: "social@brimfinancial.com" },
          { or: [
            { subject: "Your foreign purchase was successful" },
            { subject: "Your Payment Was Received" },
          ]},
        ]},

        { from: "no-reply@alertsp.chase.com" },

        { from: "ebill@conservicemail.com" },

        { and: [
          { from: "endesa.pt@cgi.com" },
          { subject: "Documento de Pagamento Eletrónico" },
        ]},

        { and: [
          { from: "online.communications@alerts.comcast.net" },
          { subject: "Your bill is ready" },
        ]},

        { and: [
          { from: "alert@eqbank.ca" },
          { subject: "EQ Bank: EFT withdrawal" },
        ]},

        { and: [
          { from: "help@accts.epicgames.com" },
          { subject: "Your Epic Games Receipt" },
        ]},

        { from: "faturacao.eletronica@galp.com" },

        { from: "googlepay-noreply@google.com" },
        { from: "payments-noreply@google.com" },

        { and: [
          { from: "no-reply@glovoapp.com" },
          { or: [
            { subject: "As suas faturas" },
            { subject: "Details of your glovo" },
            { subject: "Details of your order" },
            { subject: "Detalhes do teu pedido" },
            { subject: "Glovo Confirmation" },
          ]},
        ]},

        { and: [
          { or: [
            { from: "catch@payments.interac.ca" },
            { from: "notify@payments.interac.ca" },
          ]},
          { subject: "INTERAC e-Transfer: Your funds" },
          { subject: "INTERAC e-Transfer: Your money transfer to REMITBEE INCORPORATED was deposited." },
        ]},

        { from: "billing@mailgun.net" },

        { and: [
          { from: "banco@millenniumbcp.pt" },
          { or: [
            { subject: "Documentos em formato digital" },
            { subject: "Extrato Combinado" },
          ]},
        ]},

        { from: "renewals@namecheap.com" },
        { from: "support@namecheap.com" },

        { and: [
          { from: "service@paypal.com" },
          { subject: "Receipt for Your Payment" },
        ]},

        { from: "CustomerServiceOnline@billpay.pge.com" },

        { and: [
          { from: "facturaelectronica@pingodoce.pt" },
          { subject: "Fatura Eletrónica Pingo Doce" },
        ]},

        { and: [
          { or: [
            { from: "customercare@remitbee.com" },
            { from: "noreply@account.remitbee.com" },
            { from: "transaction@remitbee.com" },
          ]},
          { or: [
            { subject: "ACTION REQUIRED: - Steps for Interac E- Transfer Auto-deposit" },
            { subject: "Action Required: Transaction pending due to documents" },
            { subject: "RemitBee - Funds were deposited into your RB balance" },
            { subject: "RemitBee Transaction Receipt" },
            { subject: "Remitbee - Transaction Completed Successfully" },
            { subject: "Remitbee - funds were deposited into your Wallet" },
          ]},
        ]},

        { and: [
          { from: "noreply@steampowered.com" },
          { subject: "Thank you for your Steam purchase!" },
        ]},

        { from: "noreply@uber.com" },
        { from: "uber.us@uber.com" },

        { and: [
          { from: "apoiocliente@vodafone.pt" },
          { subject: "Faturação Vodafone" },
        ]},

        { and: [
          { or: [
            { from: "notifications@o.wealthsimple.com" },
            { from: "support@wealthsimple.com" },
          ]},
          { or: [
            { subject: "Direct deposit received" },
            { subject: "You earned a dividend" },
            { subject: "You made a deposit" },
            { subject: "You sent a bill payment" },
            { subject: "You've withdrawn funds from Wealthsimple" },
            { subject: "Your deposit is complete!" },
            { subject: "Your deposit is on the way!" },
            { subject: "Your transfer is complete!" },
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
            { subject: "Your funds have been converted" },
            { subject: "Your order has been cancelled" },
            { subject: "Your order has been filled" },
            { subject: "Your transfer is complete!" },
            { subject: "Your transfer is on its way!" },
            { subject: "Your order has been rejected" },
            { subject: "Your order has expired" },
          ]},
        ]},
      ],
    },
    actions: label("Cash/Invest"),
  },
  {
    filter: {
      or: [
        { from: "architect-newsletter@mailer.infoq.com" },
        { from: "betterengineers@substack.com" },
        { from: "buzzrobot@substack.com" },
        { from: "daily@chartr.co" },
        { from: "lex@sreweekly.com" },
        { from: "notifications@e-news.wealthsimple.com" },
      ],
    },
    actions: label("News/Lists"),
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
  { name: "Events" },
  { name: "Family" },
  { name: "Jobs" },
  { name: "News" },
  { name: "News/Lists" },
  { name: "RSS" },
  { name: "Property" },
  { name: "Property/FerreiraBorges" },
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
