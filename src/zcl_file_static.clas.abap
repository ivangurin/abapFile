class ZCL_FILE_STATIC definition
  public
  final
  create public .

*"* public components of class ZCL_FILE_STATIC
*"* do not include other source files here!!!
public section.

  types:
    begin of ts_file,
        name type string,
        size type i,
        data type xstring,
      end of ts_file .
  types:
    tt_files type table of ts_file .

  class-methods IS_EXIST
    importing
      !I_PATH type SIMPLE
    returning
      value(E_EXIST) type ABAP_BOOL
    raising
      ZCX_GENERIC .
  class-methods READ
    importing
      !I_PATH type STRING
      !I_TYPE type C default 'BIN'
    returning
      value(E_DATA) type XSTRING
    raising
      ZCX_GENERIC .
  class-methods READ_CSV
    importing
      !I_PATH type SIMPLE
    exporting
      !ET_DATA type TABLE
    raising
      ZCX_GENERIC .
  class-methods SAVE
    importing
      !I_TYPE type C default 'BIN'
      !I_PATH type SIMPLE
      !I_DATA type XSTRING
    raising
      ZCX_GENERIC .
  class-methods SAVE_CSV
    importing
      !I_PATH type SIMPLE
      !IT_DATA type TABLE
    raising
      ZCX_GENERIC .
  class-methods DELETE
    importing
      !I_PATH type SIMPLE
    raising
      ZCX_GENERIC .
  class-methods GET_FILE
    importing
      !I_PATH type SIMPLE
    returning
      value(E_FILE) type STRING .
  class-methods GET_NAME
    importing
      !I_PATH type SIMPLE
    returning
      value(E_NAME) type STRING .
  class-methods GET_EXTENSION
    importing
      !I_PATH type SIMPLE
    returning
      value(E_EXTENSION) type STRING .
  class-methods GET_MIME
    importing
      !I_PATH type SIMPLE
    returning
      value(E_MIME) type STRING .
  class-methods SPLIT_PATH
    importing
      !I_PATH type SIMPLE
    exporting
      !E_FILE type STRING
      !E_PATH type STRING .
  class-methods SAVE_TO_SERVER
    importing
      !I_PATH type SIMPLE
      !I_DATA type XSTRING
    raising
      ZCX_GENERIC .
  class-methods READ_FROM_SERVER
    importing
      !I_PATH type SIMPLE
    returning
      value(E_DATA) type XSTRING
    raising
      ZCX_GENERIC .
  class-methods EXECUTE
    importing
      !I_PATH type SIMPLE
    raising
      ZCX_GENERIC .
  class-methods OPEN_DIALOG
    importing
      !I_FILTER type SIMPLE optional
    returning
      value(E_PATH) type STRING
    raising
      ZCX_GENERIC .
  class-methods SAVE_DIALOG
    importing
      !I_FILE type SIMPLE optional
    returning
      value(E_PATH) type STRING
    raising
      ZCX_GENERIC .
  protected section.
*"* protected components of class ZCL_FILE_STATIC
*"* do not include other source files here!!!
  private section.
*"* private components of class ZCL_FILE_STATIC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_FILE_STATIC IMPLEMENTATION.


  method delete.

    data l_path type string.
    l_path = i_path.

    data l_rc type i.
    call method cl_gui_frontend_services=>file_delete
      exporting
        filename             = l_path
      changing
        rc                   = l_rc
      exceptions
        file_delete_failed   = 1
        cntl_error           = 2
        error_no_gui         = 3
        file_not_found       = 4
        access_denied        = 5
        unknown_error        = 6
        not_supported_by_gui = 7
        wrong_parameter      = 8
        others               = 9.
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method execute.

    data l_document type string.
    l_document = i_path.

    cl_gui_frontend_services=>execute(
      exporting
        document = l_document
      exceptions
        others = 1 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method get_extension.

    data lv_file type string.
    lv_file = get_file( i_path ).

    data lv_name type string.
    find regex '(.*)[.](.*)' in lv_file submatches lv_name e_extension.

  endmethod.


  method get_file.

    data lv_path type string.
    find regex '(.*)[\\](.*)' in i_path submatches lv_path e_file.
    if sy-subrc ne 0.
      e_file = i_path.
    endif.

  endmethod.


  method get_mime.

    data l_extension(10).
    l_extension = get_extension( i_path ).

    data l_mime type w3conttype.
    call function 'SDOK_MIMETYPE_GET'
      exporting
        extension = l_extension
      importing
        mimetype  = l_mime.

    e_mime = l_mime.

  endmethod.


  method get_name.

    data lv_file type string.
    lv_file = get_file( i_path ).

    data lv_extension type path.
    find regex '(.*)[.](.*)' in lv_file submatches e_name lv_extension.
    if sy-subrc ne 0.
      e_name = lv_file.
    endif.

  endmethod.


  method is_exist.

    data l_path type string.
    l_path = i_path.

    call method cl_gui_frontend_services=>file_exist
      exporting
        file                 = l_path
      receiving
        result               = e_exist
      exceptions
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        not_supported_by_gui = 4
        others               = 5.
    if sy-subrc <> 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method OPEN_DIALOG.

    data l_filter type string.
    l_filter = i_filter.

    data lt_files type filetable.
    data l_rc type i.
    cl_gui_frontend_services=>file_open_dialog(
      exporting
        file_filter = l_filter
      changing
        file_table  = lt_files
        rc          = l_rc
      exceptions
        others      = 1 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    data ls_file like line of lt_files.
    read table lt_files into ls_file index 1.

    e_path = ls_file-filename.

  endmethod.


  method read.

    data l_size type i.
    data lt_data type table of raw128.
    cl_gui_frontend_services=>gui_upload(
      exporting
        filename                = i_path
        filetype                = i_type
      importing
        filelength              = l_size
      changing
        data_tab                = lt_data
      exceptions
        others                  = 1 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    data l_data like line of lt_data.
    loop at lt_data into l_data.
      if sy-tabix eq 1.
        e_data = l_data.
      else.
        concatenate e_data l_data into e_data in byte mode.
      endif.
    endloop.

    e_data = e_data(l_size).

  endmethod.


  method read_csv.

    data lt_data type stringtab.
    cl_gui_frontend_services=>gui_upload(
      exporting
        filename                = i_path
        filetype                = 'ASC'
      changing
        data_tab                = lt_data
      exceptions
        others                  = 1 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    zcl_convert_static=>csv2table(
      exporting it_data = lt_data
      importing et_data = et_data ).

  endmethod.


  method read_from_server.

    data l_path type string.
    l_path = i_path.

    " Îòêðûâàåì ôàéë íà çàïèñü
    data l_message type string.
    open dataset l_path for input in binary mode message l_message.
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    " Ïåðåíîñèì äàííûå
    read dataset l_path into e_data.

    " Çàêðûâàåì ôàéë
    close dataset l_path.

  endmethod.


  method save.

    data l_path type string.
    l_path = i_path.

    data l_size type i.
    l_size = xstrlen( i_data ).

    data lt_data type tsfixml.
    zcl_convert_static=>xtext2xtable(
      exporting i_data  = i_data
      importing et_data = lt_data ).

    cl_gui_frontend_services=>gui_download(
      exporting
        bin_filesize            = l_size
        filename                = l_path
        filetype                = i_type
      changing
        data_tab                = lt_data
      exceptions
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        others                  = 24 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method save_csv.

    data l_path type string.
    l_path = i_path.

    data lt_data type stringtab.
    lt_data =
      zcl_convert_static=>table2csv(
        it_data = it_data ).

    cl_gui_frontend_services=>gui_download(
      exporting
        filename                = l_path
        filetype                = 'ASC'
      changing
        data_tab                = lt_data
      exceptions
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        others                  = 24 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method SAVE_DIALOG.

    data l_file type string.
    l_file = i_file.

    data l_path type string.
    cl_gui_frontend_services=>file_save_dialog(
      exporting
        default_file_name    = l_file
      changing
        filename             = l_file
        path                 = l_path
        fullpath             = e_path
      exceptions
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        others               = 4 ).
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

  endmethod.


  method save_to_server.

    data l_path type string.
    l_path = i_path.

    " Îòêðûâàåì ôàéë íà çàïèñü
    data l_message type string.
    open dataset l_path for output in binary mode message l_message.
    if sy-subrc ne 0.
      zcx_generic=>raise( ).
    endif.

    " Ïåðåíîñèì äàííûå
    transfer i_data to l_path.

    " Çàêðûâàåì ôàéë
    close dataset l_path.

  endmethod.


  method split_path.

    find regex '(.*)[/](.*)' in i_path submatches e_path e_file.
    if sy-subrc ne 0.
      e_file = i_path.
      e_path = i_path.
    endif.

  endmethod.
ENDCLASS.
