// vim: set shiftwidth=2
// IMPORTANT: use the `gmailctlw edit` command to modify this file!
local lib = import "gmailctl.libsonnet";
local me = "kjames@dialpad.com";
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
    filter: {
      from: "alerts@okta.com"
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
        { to: "gcp-notifications@dialpad.com" },
        { to: "outage@dialpad.com" },
      ],
    },
    actions: labelAndArchive("Alerts", markRead=false),
  },
  {
    filter: {
      or: [
        { and: [
          listProduct,
          { or: [
            { from: "BlazeMeter" },
            { from: "Google Cloud Alerting" },
            { from: "Stackdriver" },
            { from: "devalerts@dialpad.com" },
            { subject: "Cannot cancel applied-dev.com office for fraud" },
            { subject: "Failed to assign did to invited user" },
            { subject: "WRITE OPERATION WARNING" },
          ]},
        ]},
        { from: "firebase-noreply@google.com" },
        { to: "engineering+buildbreak@dialpad.com" },
        { and: [
          { replyto: "sales@pusher.com" },
          { subject: "Approaching your limits" },
        ]},
      ],
    },
    actions: labelAndArchive("Alerts/Product"),
  },
  {
    filter: {
      or: [
        { and: [
          listTelephony,
          { or: [
            { from: "Datadog Alerting" },
            { from: "Datadog" },
            { from: "DigiCert" },
            { from: "devalerts@dialpad.com" },
            { from: "devalerts@firespotter.com" },
            { from: "help@status.dtdg.co" },
            { from: "noreply@statuspage.io" },
            { subject: "WRITE OPERATION WARNING" },
            { to: "monitoring@dialpad.com" },
            { to: "no-reply@alerts.rackspacecloud.com" },
          ]},
        ]},
        { from: "*@axtel.com.mx" },
        { from: "CTIE IR.COM" },
        { from: "PlannedWorks@colt.net" },
        { from: "gijyutu@t-catv.co.jp" },
        { from: "gsd@bbix.net" },
        { from: "hiroki.nakamura@rakuten.com" },
        { from: "hirotani@winknet.ne.jp" },
        { from: "idc@synapse.jp" },
        { from: "ircom@ctie.etat.lu" },
        { from: "network-update@bandwidth.com" },
        { from: "no-reply@alerts.rackspacecloud.com" },
        { from: "no-reply@equinix.com" },
        { from: "no-reply@voxbone.com" },
        { from: "peering@axelnetworks.co.jp" },
        { from: "ry-kadekaru@otnet.co.jp" },
        { from: "rymatsumoto@bbtower.co.jp" },
        { from: "ryou.sakamoto.fc@s1.nttdocomo.com" },
        { from: "somostexting@somos.com" },
        { from: "support@thousandeyes.com" },
        { from: "yokoyama@nsg.kcv.ne.jp" },
        { from: "yoshida@ncm.ad.jp" },
        { from: "yus-takahashi@enecom.co.jp" },
        { subject: "New error in fstelephony" },
        { to: "telephony+accessdenied@dialpad.com" },
        { to: "telephony+carrieralert@dialpad.com" },
        { to: "telephony+datadogalerts@dialpad.com" },
        { to: "telephony+didprobes" },
        { to: "telephony+exceptions@dialpad.com" },
        { to: "telephony+interregionroute@dialpad.com" },
        { to: "telephony+interregionroute@firespotter.com" },
        { to: "telephony+ivona@dialpad.com" },
        { to: "telephony+pagerdutysilence@dialpad.com" },
        { to: "telephony+removeuri@dialpad.com" },
        { to: "telephony+routediderrors@dialpad.com" },
        { to: "telephony+smsspam@dialpad.com" },
        { to: "telephony+transcription@dialpad.com" },
        { to: "telephony+verify_hangup_failure@dialpad.com" },
        { and: [
          { from: "telephony@dialpad.com" },
          { subject: "Cloud Server Incident Notification" },
        ]},
      ],
    },
    actions: labelAndArchive("Alerts/Telephony"),
  },
  {
    filter: {
      or: [
        { and: [
          listVoiceAI,
          { from: "Stackdriver Alerts" },
        ]},
        { and: [
          { to: me },
          { from: "no-reply@pagerduty.com" },
        ]},
      ],
    },
    actions: {
      markImportant: true,
      labels: [ "Alerts/VoiceAI" ],
    },
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
      ],
    },
    actions: labelAndArchive("Billing"),
  },
  {
    filter: {
      and: [
        listTelephony,
        { or: [
          { from: "Cobranza Alestra" },
          { from: "support@smarty.com" },
          { subject: "Lumen (former Level 3) International Rates" },
          { and: [
            { from: "cloud@vagrantup.com" },
            { subject: "Receipt for payment" },
          ]},
          { and: [
            { from: "HashiCorp, Inc" },
            { subject: "Your receipt from HashiCorp" },
          ]},
        ]},
      ]
    },
    actions: labelAndArchive("Billing/Telephony"),
  },
  {
    filter: {
      or: [
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
          ]},
        ]},
        { subject: "OpenAI API Invoice" },
      ],
    },
    actions: labelAndArchive("Billing/VoiceAI"),
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
      ],
    },
    actions: labelAndArchive("CI"),
  },
  {
    filter: {
      and: [
        listProduct,
        { or: [
          { subject: "pushed to version" },
          { from: "Travis CI" },
        ]},
      ],
    },
    actions: labelAndArchive("CI/Product"),
  },
  {
    filter: {
      and: [
        listTelephony,
        { or: [
          { from: "Travis CI" },
          { subject: "[Diffusion]" },
        ]},
      ],
    },
    actions: labelAndArchive("CI/Telephony"),
  },
  {
    filter: {
      and: [
        listVoiceAI,
        { from: "builds@circleci.com" },
      ],
    },
    actions: labelAndArchive("CI/VoiceAI"),
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
      and: [
        listTelephony,
        { subject: "Telephony Infrastructure Team Meeting" },
      ],
    },
    actions: labelAndArchive("Meetings"),
  },
  {
    filter: {
      from: "dnb.com"
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
      or: [
        { and: [
          listTelephony,
          { from: "yourdomosummary@domo.com" },
        ]},
        { from: "CustomerComms@colt.net" },
        { from: "carrier-rates@dialpad.com" },
        { from: "carrier-rates@firespotter.com" },
        { from: "clientes@axtel.com.mx" },
        { from: "info@colt.net" },
        { from: "info@somos.com" },
        { from: "netpromoter@rackspace.com" },
        { from: "sales@teleinx.com" },
        { from: "sales@voxbone.com" },
        { to: "carrier-rates@dialpad.com" },
        { to: "carrier-rates@firespotter.com" },
        { to: "clientes@axtel.com.mx" },
      ],
    },
    actions: labelAndArchive("Newsletter/Telephony"),
  },
  {
    filter: {
      or: [
        { subject: "ASR model release notes" },
        { and: [
          { list: "vi-leads@dialpad.com" },
          { or: [
            { subject: "End of Week Updates" },
            { subject: "NLP weekly OKR progress" },
            { subject: "Weekly Project Progress" },
          ]},
        ]},
      ],
    },
    actions: labelAndArchive("Newsletter/VoiceAI"),
  },
  {
    filter: {
      and: [
        { list: "team@dialpad.com" },
        { or: [
          { subject: "[Dialpad Release Notes]" },
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
          listProduct,
          { subject: "On-Call summary" },
        ]},
        { and: [
          { to: "deploy@dialpad.com" },
          { subject: "pushed to version" },
        ]},
        { subject: "[READ THIS] Eng/QA Thread" },
        { subject: "[READ THIS] Dialpad | ENG/QA Thread" },
      ],
    },
    actions: labelAndArchive("Release/Product"),
  },
  {
    filter: {
      and: [
        listTelephony,
        { or: [
          { subject: "On call summary" },
          { subject: "Telephony build ready for QA" },
          { subject: "ready for QA" },
        ]},
      ],
    },
    actions: labelAndArchive("Release/Telephony"),
  },
  {
    filter: {
      and: [
        { from: "esupport@google.com" },
        { subject: "New Case Comment" },
      ],
    },
    actions: labelAndArchive("Support", markRead=false),
  },
  {
    filter: {
      and: [
        listProduct,
        { or: [
          { subject: "GAE Version Cleanup Summary" },
          { and: [
            { from: "uveng@dialpad.com" },
            { subject: "New Case Comment" },
          ]},
        ]},
      ],
    },
    actions: labelAndArchive("Support/Product"),
  },
  {
    filter: {
      or: [
        { from: "9-1-1ESO" },
        { from: "Autonotifications2@colt.net" },
        { from: "BICS noreply" },
        { from: "Bandwidth Support" },
        { from: "CrtQueryEngine" },
        { from: "Inteliquent Communications" },
        { from: "Inteliquent Network Operations Center" },
        { from: "Inteliquent Notifications" },
        { from: "NLnpdesk@colt.net" },
        { from: "Rackspace" },
        { from: "Voxbone Regulations" },
        { from: "autonotifications@colt.net" },
        { from: "bbix-sales@bbix.net" },
        { from: "covidcomms@colt.net" },
        { from: "customerportal@symbio.global" },
        { from: "customerportal@symbionetworks.com" },
        { from: "hannah.beard@colt.net" },
        { from: "no-reply@didww.com" },
        { from: "noreply@tickets.rackspace.com" },
        { from: "noreply@tollfree.exchange" },
        { from: "notification@somos.com" },
        { from: "smc.ngnsip.tiws@telefonica.com" },
        { from: "smc@level3.com" },
        { from: "support@alcazarnetworks.com" },
        { to: "GermanyPortingDesk@colt.net" },
        { to: "aws-admin@dialpad.com" },
        { to: "carrier-support@dialpad.com" },
        { to: "carrier-support@firespotter.com" },
        { to: "ipnoc@dialpad.com" },
        { to: "noc@dialpad.com" },
        { to: "noreply@tickets.rackspace.com" },
        { to: "telephony+cloudhelix@dialpad.com" },
        { to: "telephony+fstelephony-elasticco@dialpad.com" },
        { to: "telephony+fststaging-elasticco@dialpad.com" },
        { and: [
          listTelephony,
          { from: "noreply@digicert.com" },
        ]},
        { and: [
          { from: "noreply@bandwidth.com" },
          { subject: "Shared Endpoint Report" },
        ]},
        { and: [
          { from: "telephony@dialpad.com" },
          { subject: "New Case Comment" },
        ]},
      ],
    },
    actions: labelAndArchive("Support/Telephony"),
  },
  {
    filter: {
      and: [
        listVoiceAI,
        { or: [
          { from: "Upwork Notification" },
          { from: "Upwork" },
          { from: "messenger@e.west.com" },
          { replyto: "support@elastic.co" },
        ]},
      ],
    },
    actions: labelAndArchive("Support/VoiceAI", markRead=false),
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
  {
    name: "Alerts/Product",
    color: {
      background: "#fb4c2f",
      text: "#ffffff"
    }
  },
  {
    name: "Alerts/Telephony",
    color: {
      background: "#fb4c2f",
      text: "#ffffff"
    }
  },
  {
    name: "Alerts/VoiceAI",
    color: {
      background: "#fb4c2f",
      text: "#ffffff"
    }
  },
  { name: "Billing" },
  { name: "Billing/Telephony" },
  { name: "Billing/VoiceAI" },
  { name: "Calendar" },
  { name: "CI" },
  { name: "CI/Product" },
  { name: "CI/Telephony" },
  { name: "CI/VoiceAI" },
  { name: "Expenses" },
  { name: "Hiring" },
  { name: "Jira" },
  { name: "Meetings" },
  { name: "Newsletter" },
  { name: "Newsletter/CSR" },
  { name: "Newsletter/DataScience" },
  { name: "Newsletter/Product" },
  { name: "Newsletter/Telephony" },
  { name: "Newsletter/VoiceAI" },
  { name: "Newsletter/VoiceAI/Competition" },
  { name: "Newsletter/VoiceAI/Feedback" },
  { name: "Newsletter/VoiceAI/Feedback/User" },
  { name: "Release" },
  { name: "Release/Product" },
  { name: "Release/Telephony" },
  { name: "Support" },
  { name: "Support/Product" },
  { name: "Support/Telephony" },
  { name: "Support/VoiceAI" },
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
