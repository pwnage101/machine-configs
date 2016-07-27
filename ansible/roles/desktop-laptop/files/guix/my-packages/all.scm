(define-module (my-packages all)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages xorg))

(define suckess-git-uri-prefix "http://git.suckless.org/")

(define* (suckless-tool #:key existing-package commit hash patches inputs)
  (let* ((package-name (symbol->string existing-package))
         (package
           (primitive-eval (append
             `(package (inherit ,existing-package)
               (name ,package-name)
               (version ,(string-append "troy-" (string-take commit 4)))
               (source ,(origin
                         (method git-fetch)
                         (uri (git-reference
                                (url (string-append suckess-git-uri-prefix package-name))
                                (commit commit)))
                         (sha256 (base32 hash)))))
             (if (eq? patches #f) '() `((patches ,patches)))
             (if (eq? inputs #f) '() `((inputs ,inputs))))))
         (definition
           `(define-public
             ,(string->symbol (string-append "troy-" package-name))
             ,package)))
    (primitive-eval definition)))
;
;(define* (make-suckles-package #:key existing-package commit hash patches inputs)
;  (primitive-eval (append
;    `(package (inherit existing-package)
;      (name package-name)
;      (version ,(string-append "troy-" (string-take commit 4)))
;      (source (origin
;                (method git-fetch)
;                (uri (git-reference
;                       (url ,(string-append suckess-git-uri-prefix name))
;                       (commit ,commit)))
;                (sha256 (base32 ,hash)))))
;    (if (eq? patches #f) '() `((patches ,patches)))
;    (if (eq? inputs #f) '() `((inputs ,inputs))))))
;
;(define-syntax define-suckless-package
;  
;  (syntax-rules ()
;    ((_ test e e* ...)
;     (if test (begin e e* ...)))))
;


(suckless-tool
  #:existing-package 'dmenu
  #:commit "b3d9451c2ddfad7c1b10e9a868afed4d92b37e41"
  #:hash "1mg7x2s2fknjrfh7m9qs91gvj570hqc79fb9f6nfz3v823k09pys"
  #:inputs `(
    ("libx11" ,libx11)
    ("libxft" ,libxft)
    ("libxinerama" ,libxinerama)))

(suckless-tool
  #:existing-package 'slock
  #:commit "65b8d5278882310eed758e6fbfd6ab9676db883c"
  #:hash "0761q133d7p4zlzph5z8v5nd8ccwxi2f14x3h1failn0k1pa4gyw"
  #:patches (list
    "slock-01-Ctrl-u-resets-input.patch"))

;(define-public my-dmenu
;  (let ((commit "b3d9451c2ddfad7c1b10e9a868afed4d92b37e41"))
;    (package (inherit dmenu)
;      (name "dmenu")
;      (version (string-append "troy-" (string-take commit 4)))
;      (source (origin
;                (method git-fetch)
;                (uri (git-reference
;                       (url (string-append suckess-git-uri-prefix name))
;                       (commit commit)))
;                (sha256
;                 (base32
;                  "1mg7x2s2fknjrfh7m9qs91gvj570hqc79fb9f6nfz3v823k09pys"))
;      (inputs `(
;        ("libx11" ,libx11)
;        ("libxft" ,libxft)
;        ("libxinerama" ,libxinerama)
;        )))))))
;
;
;(define-public my-slock
;  (let ((commit "65b8d5278882310eed758e6fbfd6ab9676db883c"))
;    (package (inherit slock)
;      (name "slock")
;      (version (string-append "troy-" (string-take commit 4)))
;      (source (origin
;                (method git-fetch)
;                (uri (git-reference
;                       (url (string-append suckess-git-uri-prefix name))
;                       (commit commit)))
;                (sha256
;                 (base32
;                  "0761q133d7p4zlzph5z8v5nd8ccwxi2f14x3h1failn0k1pa4gyw"))
;                (patches (search-patches
;                           "slock-01-Ctrl-u-resets-input.patch"
;                  )))))))

(define-public my-st
  (let ((commit "ff241199edc7631d6599c22414ef6823059a1072"))
    (package (inherit st)
      (name "st")
      (version (string-append "troy-" (string-take commit 4)))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url (string-append suckess-git-uri-prefix name))
                       (commit commit)))
                (sha256
                 (base32
                  "13daz37p8xxvz2b4hz8jzjlv66hh0z50sdf23q8ykbw66dbqv4ms"))
                (patches (search-patches
                           "st-00-config.patch"
                  )))))))

(define-public my-surf
  (let ((commit "f5e8baad06eafef22df12ab2649139260127d4e4"))
    (package (inherit surf)
      (name "surf")
      (version (string-append "troy-" (string-take commit 4)))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url (string-append suckess-git-uri-prefix name))
                       (commit commit)))
                (sha256
                 (base32
                  "1fa2sr0nks72ys2kmbk6bqfbvnpjv93dafr8zhwsnhn8vcq9jg24"))
                (patches (search-patches
                           "surf-00-config.patch"
                  )))))))
