
<!-- vim-markdown-toc GFM -->

* [Example TPM2.0 Endorsement Key certificates](#example-tpm20-endorsement-key-certificates)
* [`tpm2_getcap` dumps](#tpm2_getcap-dumps)

<!-- vim-markdown-toc -->


### Example TPM2.0 Endorsement Key certificates

The TCG publishes example Endorsement Key certificates in appendix A of the
[TCG EK Credential Profile][tcg-ekcp] (specification 2.0 revision 14).

```
└── ek_certificates/
    ├── tcg-example-user-device.der
    ├── tcg-example-user-device--annotated.pem
    ├── tcg-example-nonuser-device.der
    └── tcg-example-nonuser-device--annotated.pem
```

### `tpm2_getcap` dumps

The files that mock TPM2 data returned by `tpm2_getcap -c properties-fixed`
are derived from publicly-available sources on the internet:

```
└── tpm2_getcap_-c_properties-fixed/
    ├── infineon-slb9670.yaml         # https://github.com/tpm2-software/tpm2-tools/issues/407#issuecomment-323237350
    ├── nationz-z32h320tc.yaml        # https://github.com/tpm2-software/tpm2-tools/issues/335#issuecomment-339525716
    ├── nuvoton-ncpt6xx-fbfc85e.yaml  # https://www.commoncriteriaportal.org/files/epfiles/anssi-cible2017_55en.pdf
    └── nuvoton-ncpt7xx-lag019.yaml   # https://www.commoncriteriaportal.org/files/epfiles/anssi-cible-cc-2017_75en.pdf
```

[tcg-ekcp]: https://www.trustedcomputinggroup.org/wp-content/uploads/Credential_Profile_EK_V2.0_R14_published.pdf
