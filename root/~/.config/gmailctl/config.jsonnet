{
  version: "v1alpha3",
  author: {
    name: "Kevin James",
    email: "kevin.j.carruthers@gmail.com"
  },
  rules: [
    {
      filter: {
        from: "billing@mailgun.net"
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "bot@fanfiction.com"
      },
      actions: {
        archive: true,
        labels: [
          "RSS"
        ]
      }
    },
    {
      filter: {
        from: "bot@fictionpress.com"
      },
      actions: {
        archive: true,
        labels: [
          "RSS"
        ]
      }
    },
    {
      filter: {
        from: "Chase QuickPay Team",
        isEscaped: true
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "CustomerServiceOnline@billpay.pge.com"
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "ebill@conservicemail.com"
          },
          {
            subject: "Conservice bill",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "googlepay-noreply@google.com"
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "noreply@haveibeenpwned.com"
      },
      actions: {
        archive: true,
        labels: [
          "Security"
        ]
      }
    },
    {
      filter: {
        from: "noreply@robinhood.com"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "Bills/Stock"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "noreply@steampowered.com"
          },
          {
            subject: "Thank you for your Steam purchase!",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "notifications@robinhood.com"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "Bills/Stock"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "online.communications@alerts.comcast.net"
          },
          {
            subject: "Your bill is ready",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "payments-noreply@google.com"
          },
          {
            subject: "Your Google Fi monthly statement",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "renewals@namecheap.com"
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "service@paypal.com"
          },
          {
            subject: "Receipt for Your Payment",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        from: "support@namecheap.com"
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    },
    {
      filter: {
        and: [
          {
            from: "support@wealthfront.com"
          },
          {
            subject: "Investment prospectus",
            isEscaped: true
          }
        ]
      },
      actions: {
        archive: true,
        labels: [
          "News"
        ]
      }
    },
    {
      filter: {
        from: "uber.us@uber.com ",
        isEscaped: true
      },
      actions: {
        archive: true,
        labels: [
          "Bills"
        ]
      }
    }
  ]
}
