
MOD_ID = "remake"
MOD_VERSION = "1.0.0"
DEV_MODE = true

function register() 
    return {
      name = MOD_ID,
      modules = {
          --Objects
          "obj_raintank",
          "obj_trash_bin",
          "obj_auto_squeezer",
          "obj_auto_centrifuge",

          --Utils
          "util_logger",
          "util_slot_utilities",
          "util_hive_utilities",
          "util_auto_machine_utilities",
          "util_utilities"
      }
    }
end

function init()

    raintank.register()
    trash_bin.register()
    auto_squeezer.register()
    auto_centrifuge.register()

    if (DEV_MODE) then
        api_set_devmode(true)
    end

    return "Success"
end