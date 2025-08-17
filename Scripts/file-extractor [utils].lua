    local filepath = ""
    local extractionpath = ""
    local pass = ""
    menu.add_text("----File Extractor----")
    menu.add_input_text("File Path")
    menu.set_text("File Path", filepath)
    menu.add_input_text("Etraction Path")
    menu.set_text("Etraction Path", extractionpath)
    menu.add_input_text("Pass")
    menu.set_text("Pass", pass)
    menu.add_check_box("Delete After Extraction")
    menu.add_button("Extract")
    menu.add_text("---------------------")

    settings.load()
    
    local function extractfile()
        filepath = menu.get_text("File Path")
        extractionpath = menu.get_text("Etraction Path")
        pass = menu.get_text("Pass")
        local deleteafterextraction = menu.get_bool("Delete After Extraction")
        if file.exists(filepath) then
            zip.extract(filepath, extractionpath, deleteafterextraction, pass)
            settings.save()
        end
    end

    client.add_callback("on_button_Extract", extractfile)

