if exists('g:latex_pdf_viewer')
    let s:pdf_viewer = g:latex_pdf_viewer
else 
    for possible_pdf in ['okular', 'mupdf', 'evince']
        if executable(possible_pdf)
            let s:pdf_viewer = possible_pdf
        endif
    endfor
endif

if (!exists('s:pdf_viewer'))
    echoh1 ErrorMsg
    echo "could not find valid pdf viewer"
    echoh1 None
    finish
endif

if (!exists('g:latex_engine'))
    let g:latex_engine = 'pdflatex'
endif

if exists(':AsyncRun') && v:version >= 800
    let s:async_support = 1
endif


function! s:CompileLatex()
    if exists('s:async_support')
        execute ":AsyncRun " . g:latex_engine . " % && pkill -HUP mupdf"
    else
        execute "silent !". g:latex_engine. " % &>/dev/null && pkill -HUP mupdf &> /dev/null"
    endif
endfunction

function! s:OpenPdf(pdf_viewer)
    execute "silent !". g:latex_engine. " % &>/dev/null && pkill -HUP mupdf &> /dev/null"
    execute "silent !" .a:pdf_viewer. " %:r.pdf &> /dev/null &"
    if exists('g:latex_preview_clean') && g:latex_preview_clean
        execute "silent ! rm *.aux *.out *.log"
    endif
    redraw!
endfunction


autocmd BufWritePost *.tex call s:CompileLatex()
command! StartLatexPreview call s:OpenPdf(s:pdf_viewer)
