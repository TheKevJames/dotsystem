// vim: set shiftwidth=2
// IMPORTANT: use the `gmailctlw edit` command to modify this file!
local lib = import "gmailctl.libsonnet";
local me = "kjames@dialpad.com";
local listElasticsearch = {
  list: "elasticsearch-admins@dialpad.com",
};
local listProduct = {
  list: "uveng@dialpad.com",
};
local listTelephony = {
  or: [
    { list: "tel-eng@dialpad.com" },
    { list: "tel-eng-guest@dialpad.com" },
    { list: "telephony@dialpad.com" },
  ],
};
local listVoiceAI = {
  or: [
    { list: "voiceai-eng@dialpad.com" },
    { list: "ops@talkiq.com" },
  ],
};

local labelAndArchive(label, markRead=true) = {
  archive: true,
  markRead: markRead,
  markImportant: false,
  labels: [ label ],
};
local delete = {
  delete: true,
  markRead: true,
  markImportant: false
};

local rules = [
  {
    filter: listProduct,
    actions: labelAndArchive("Product"),
  },
  {
    filter: listTelephony,
    actions: labelAndArchive("Telephony"),
  },
  {
    filter: {
      or: [
        listElasticsearch,
        { from: "alerts@okta.com" },
      ],
    },
    actions: labelAndArchive("Alerts"),
  },
  {
    filter: {
      or: [
        { and: [
          { from: "noreply@statuspage.io" },
          { list: "gcp-notifications@dialpad.com" },
        ]},
        { and: [
          listVoiceAI,
          { from: "Stackdriver Alerts" },
        ]},
        { and: [
          { to: me },
          { from: "no-reply@pagerduty.com" },
        ]},
        { to: "gcp-notifications@dialpad.com" },
        { to: "outage@dialpad.com" },
      ],
    },
    actions: labelAndArchive("Alerts", markRead=false),
  },
  {
    filter: {
      or: [
        { from: "billing@grafana.com" },
        { from: "'Pusher' via UberVoice Eng" },
        { and: [
          { from: "no_reply@am.atlassian.com" },
          { subject: "invoice" },
        ]},
        { and: [
          listVoiceAI,
          { or: [
            { from: "billing@circleci.com" },
            { from: "billing@loggly.com" },
            { from: "no-reply@uptimerobot.com" },
            { subject: "CircleCI Payment Confirmation" },
            { subject: "Cloudflare Purchase Confirmation" },
            { and: [
              { from: "Amazon Web Services" },
              { subject: "Amazon Web Services Billing Statement" },
            ]},
            { and: [
              { from: "Elastic Cloud" },
              { subject: "We received your payment" },
            ]},
            { and: [
              { replyto: "noreply@notify.cloudflare.com" },
              { subject: "Your Cloudflare Invoice is Available" },
            ]},
            { and: [
              { from: "no-reply@cloud.ibm.com" },
              { subject: "IBM Cloud Billing" },
            ]},
            { subject: "Your Circle Internet Services, Inc receipt" },
            { subject: "Your receipt from Circle Internet Services" },
            { subject: "[Statement] CircleCI Subscription" },
          ]},
        ]},
        { subject: "OpenAI API Invoice" },
      ],
    },
    actions: labelAndArchive("Billing"),
  },
  {
    filter: {
      and: [
        { query: "Google Calendar" },
        { or: [
          { subject: "Accepted" },
          { subject: "Declined" },
          { subject: "Invitation" },
          { subject: "Updated invitation" },
        ]},
      ],
    },
    actions: labelAndArchive("Calendar"),
  },
  {
    filter: {
      or: [
        { to: "dialpad-dev@noreply.github.com" },
        { and: [
          { from: "Travis CI" },
          { to: "engineering@dialpad.com" },
        ]},
        { and: [
          listVoiceAI,
          { from: "builds@circleci.com" },
        ]},
      ],
    },
    actions: labelAndArchive("CI"),
  },
  {
    filter: {
      from: "concierge@expensify.com",
    },
    actions: {
      markImportant: true,
      labels: [ "Expenses" ],
    },
  },
  {
    filter: {
      or: [
        { from: "jira@switchcomm.atlassian.net" },
        { from: "jira@dialpad.atlassian.net" },
      ],
    },
    actions: labelAndArchive("Jira", markRead=false),
  },
  {
    filter: {
      or: [
        { from: "confluence@dialpad.atlassian.net" },
        { from: "dnb.com" },
        { from: "noreply@po.atlassian.net" },
        { subject: "ASR model release notes" },
        { subject: "End of Week Updates" },
        { subject: "NLP weekly OKR progress" },
        { subject: "PagerDuty Weekly Analytics" },
        { subject: "Weekly Project Progress" },
      ],
    },
    actions: labelAndArchive("Newsletter"),
  },
  {
    filter: {
      and: [
        { list: "team@dialpad.com" },
        { or: [
          { subject: "#SocialSkim" },
          { subject: "Weekly HR News Flash" },
          { subject: "Welcome our New Dialers" },
        ]},
      ],
    },
    actions: labelAndArchive("Newsletter", markRead=false),
  },
  {
    filter: {
      and: [
        { list: "team@dialpad.com" },
        { or: [
          { subject: "[Dialpad Release Notes]" },
          { subject: "[Dialpad] [TEAM] Dialpad Meetings Release Notes" },
          { subject: "[Dialpad] [TEAM] Mobile Release Notes" },
          { subject: "[READ THIS | Mobile Release Notes]" },
        ]},
      ],
    },
    actions: labelAndArchive("Release"),
  },
  {
    filter: {
      or: [
        { and: [
          { from: "esupport@google.com" },
          { subject: "New Case Comment" },
        ]},
        { and: [
          listVoiceAI,
          { or: [
            { from: "Upwork Notification" },
            { from: "Upwork" },
            { from: "messenger@e.west.com" },
            { replyto: "support@elastic.co" },
          ]},
        ]},
      ],
    },
    actions: labelAndArchive("Support", markRead=false),
  },
  {
    filter: {
      or: [
        { from: "express.com" },
        { from: "info@cedengineering.com" },
        { from: "nordstrom.com" },
        { subject: "Moderator's spam report" },
        { subject: "Your feedback matters for case" },
        { to: "uveng+apple@dialpad.com" },
        { and: [
          { list: "team@dialpad.com" },
          { from: "stickers@dialpad.com" },
        ]},
        { and: [
          { from: "noreply@dialpad.com" },
          { or: [
            { subject: "Emergency location updated" },
            { subject: "Dialpad Weekly Insights Report" },
          ]},
        ]},
        { and: [
          { from: "voicemail@dialpad.com" },
          { subject: "You have a new voicemail" },
        ]},
      ],
    },
    actions: delete,
  },
];

local labels = [
  {
    name: "Alerts",
    color: {
      background: "#fb4c2f",
      text: "#ffffff"
    }
  },
  { name: "Billing" },
  { name: "Calendar" },
  { name: "CI" },
  { name: "Expenses" },
  { name: "Hiring" },
  { name: "Jira" },
  { name: "Meetings" },
  { name: "Newsletter" },
  { name: "Payroll" },
  { name: "Product" },
  { name: "Release" },
  { name: "Release/Product" },
  { name: "Support" },
  { name: "Telephony" },
  { name: "Useful" },
  { name: "Useful/Product" },
  { name: "Useful/Telephony" },
  { name: "Visa" },
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
