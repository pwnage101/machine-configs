(define-module (my-packages all)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages xorg))

(define suckess-git-uri-prefix "http://git.suckless.org/")

; Helper function which constructs my own custom extensions of suckless
; packages.  The resulting package has the same symbol as the inherited
; package, but the version is "troy-<git commit>".
;
(define* (suckless-tool #:key package-symbol commit hash patches inputs)
  (let* ((package-name (symbol->string package-symbol))
         (new-package-name (string-append "troy-" package-name))
         (new-package
           (append
             `(package (inherit ,(primitive-eval package-symbol))
               (name ,package-name)
               (version ,(string-append "troy-" (string-take commit 4)))
               (source (origin .
                         ,(append
                           `((method ,git-fetch)
                             (uri (git-reference
                                    (url ,(string-append suckess-git-uri-prefix package-name))
                                    (commit ,commit)))
                             (sha256 (base32 ,hash)))
                           ; optionally include patches
                           (if (eq? patches #f)
                               '()
                               `((patches (quote ,(primitive-eval `(search-patches . ,patches))))))))))
             ; optionally override inputs
             (if (eq? inputs #f) '() `((inputs (quote ,inputs)))))))
    (primitive-eval
      `(define-public ,(string->symbol new-package-name)
        ,new-package))))

(suckless-tool
  #:package-symbol 'dmenu
  #:commit "b3d9451c2ddfad7c1b10e9a868afed4d92b37e41"
  #:hash "1mg7x2s2fknjrfh7m9qs91gvj570hqc79fb9f6nfz3v823k09pys"
  #:inputs `(
    ("libx11" ,libx11)
    ("libxft" ,libxft)
    ("libxinerama" ,libxinerama)))

(suckless-tool
  #:package-symbol 'slock
  #:commit "65b8d5278882310eed758e6fbfd6ab9676db883c"
  #:hash "0761q133d7p4zlzph5z8v5nd8ccwxi2f14x3h1failn0k1pa4gyw"
  #:patches '(
    "slock-01-Ctrl-u-resets-input.patch"))

(suckless-tool
  #:package-symbol 'st
  #:commit "e7ed326d2e914a57017c9f34459824614075519b"
  #:hash "13daz37p8xxvz2b4hz8jzjlv66hh0z50sdf23q8ykbw66dbqv4ms"
  #:patches '(
    "st-00-config.patch"))

(suckless-tool
  #:package-symbol 'surf
  #:commit "f5e8baad06eafef22df12ab2649139260127d4e4"
  #:hash "1fa2sr0nks72ys2kmbk6bqfbvnpjv93dafr8zhwsnhn8vcq9jg24"
  #:patches '(
    "surf-00-config.patch"))
