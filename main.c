#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <wincrypt.h>

#include <openssl/x509v3.h>

#define __CERT_NAME_LEN 1024

int main(int argc, const char **argv) {

    int                 i;
    size_t              name_size;
    size_t              name_len;
    HCERTSTORE          win_store;
    PCCERT_CONTEXT      win_ctx;
    char                *name;
    DWORD               charsConverted;
    X509                *x509;
    const unsigned char *encoded_cert;

    win_store = CertOpenSystemStoreA(
        /* [in] HCRYPTPROV_LEGACY hProv:
                  this parameter is not used and should be set to 0 */
        0,

        /* [in] LPCSTR szSubsystemProtocol:
                  a string that names a system store */
        "ROOT"
    );

    if (win_store == NULL) {
        fprintf(stderr, "Failed to open ROOT store\n");
        return 1;
    }

    name_len  = __CERT_NAME_LEN * sizeof(char);
    name_size = name_len + sizeof(char);
    name = (char *)malloc(name_size);

    if (name == NULL) {
        CertCloseStore(win_store, 0);
        fprintf(stderr, "Failed to alloc memory for the certificate name\n");
        return 1;
    }
    win_ctx = NULL;
    i = 0;

    while ((win_ctx = CertFindCertificateInStore(
            /* [in] HCERTSTORE hCertStore:
                      a handle of the certificate store to be searched */
            win_store,

            /* [in] DWORD dwCertEncodingType:
                      the type of encoding used */
            X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,

            /* [in] DWORD dwFindFlags:
                      used with some dwFindType values
                      to modify the search criteria */
            0,

            /* [in] DWORD dwFindType:
                      specifies the type of search being made */
            CERT_FIND_ANY,

            /* [in] const void *pvFindPara:
                      points to a data item or
                      structure used with dwFindType */
            NULL,

            /* [in] PCCERT_CONTEXT pPrevCertContext:
                      a pointer to the last CERT_CONTEXT
                      structure returned by this function */
            win_ctx
        )) != NULL) {

        i++;

        encoded_cert = (const unsigned char *)win_ctx->pbCertEncoded;
        x509 = d2i_X509(NULL, &encoded_cert, (long)win_ctx->cbCertEncoded);

        if (x509 != NULL) {
            charsConverted = CertGetNameStringA(
                win_ctx,
                CERT_NAME_SIMPLE_DISPLAY_TYPE,
                0,
                NULL,
                name,
                name_len
            );
            name[__CERT_NAME_LEN] = '\0';

            printf("cert [%03d], name: %s\n", i, charsConverted == 0 ? "<no name>" : name);
            X509_free(x509);
        }
    }
    free(name);
    CertCloseStore(win_store, 0);

    (void)argc;
    (void)argv;

    return 0;
}
