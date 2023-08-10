// vim: set shiftwidth=2
// IMPORTANT: use the `gmailctlp edit` command to modify this file!
local lib = import 'gmailctl.libsonnet';
local me = "kevin.j.carruthers@gmail.com";

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
        { from: "googlepay-noreply@google.com" },
        { from: "payments-noreply@google.com" },
        { from: "receipts-portugal@bolt.eu" },
        { from: "renewals@namecheap.com" },
        { from: "support@namecheap.com" },
        { from: "uber.us@uber.com" },
        { and: [
          { from: "noreply@steampowered.com" },
          { subject: "Thank you for your Steam purchase!" },
        ]},
        { and: [
          { from: "online.communications@alerts.comcast.net" },
          { subject: "Your bill is ready" },
        ]},
        { and: [
          { from: "service@paypal.com" },
          { subject: "Receipt for Your Payment" },
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
      ],
    },
    actions: label("Cash/Stock"),
  },
  {
    filter: {
      and: [
        { from: "support@wealthfront.com" },
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
