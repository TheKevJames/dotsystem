local bills = {archive: true, labels: ["Bills"]};
local news = {archive: true, labels: ["News"]};
local rss = {archive: true, labels: ["RSS"]};
local security = {archive: true, labels: ["Security"]};
local stock = {archive: true, markRead: true, labels: ["Bills/Stock"]};

{
  version: "v1alpha3",
  author: {
    name: "Kevin James",
    email: "kevin.j.carruthers@gmail.com"
  },
  rules: [
    {
      filter: {from: "billing@mailgun.net"},
      actions: bills
    },
    {
      filter: {from: "bot@fanfiction.com"},
      actions: rss
    },
    {
      filter: {from: "bot@fictionpress.com"},
      actions: rss
    },
    {
      filter: {
        from: "Chase QuickPay Team",
        isEscaped: true
      },
      actions: bills
    },
    {
      filter: {from: "CustomerServiceOnline@billpay.pge.com"},
      actions: bills
    },
    {
      filter: {
        and: [
          {from: "ebill@conservicemail.com"},
          {subject: "Conservice bill", isEscaped: true}
        ]
      },
      actions: bills
    },
    {
      filter: {from: "googlepay-noreply@google.com"},
      actions: bills
    },
    {
      filter: {from: "noreply@haveibeenpwned.com"},
      actions: security
    },
    {
      filter: {from: "noreply@robinhood.com"},
      actions: stock
    },
    {
      filter: {
        and: [
          {from: "noreply@steampowered.com"},
          {subject: "Thank you for your Steam purchase!", isEscaped: true}
        ]
      },
      actions: bills
    },
    {
      filter: {from: "notifications@robinhood.com"},
      actions: stock
    },
    {
      filter: {
        and: [
          {from: "online.communications@alerts.comcast.net"},
          {subject: "Your bill is ready", isEscaped: true}
        ]
      },
      actions: bills
    },
    {
      filter: {
        and: [
          {from: "payments-noreply@google.com"},
          {subject: "Your Google Fi monthly statement", isEscaped: true}
        ]
      },
      actions: bills
    },
    {
      filter: {from: "renewals@namecheap.com"},
      actions: bills
    },
    {
      filter: {
        and: [
          {from: "service@paypal.com"},
          {subject: "Receipt for Your Payment", isEscaped: true}
        ]
      },
      actions: bills
    },
    {
      filter: {from: "support@namecheap.com"},
      actions: bills
    },
    {
      filter: {
        and: [
          {from: "support@wealthfront.com"},
          {subject: "Investment prospectus", isEscaped: true}
        ]
      },
      actions: news
    },
    {
      filter: {from: "uber.us@uber.com"},
      actions: bills
    }
  ]
}
