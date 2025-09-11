--[[
文档_ 无

自动临时加载字体
检测当前播放目录下是否存在 fonts 文件夹，动态修改 --sub-fonts-dir

]]

local mp = require("mp")
mp.options = require("mp.options")
mp.utils = require("mp.utils")

local user_opt = {
	load = true,
}
mp.options.read_options(user_opt)

if user_opt.load == false then
	mp.msg.info("脚本已被初始化禁用")
	return
end

local fonts_dir_init = mp.get_property_native("sub-fonts-dir")
local fonts_dir_cur = fonts_dir_init
function update_fonts_dir()
	local path = mp.get_property_native("path")
	local fonts_dir = path:match("(.*[/\\])") .. "fonts"
	if fonts_dir == fonts_dir_cur or fonts_dir == fonts_dir_init then
		return
	end
	local read_success = mp.utils.readdir(fonts_dir)
	if not read_success then
		mp.set_property("sub-fonts-dir", fonts_dir_init)
		fonts_dir_cur = fonts_dir_init
		mp.msg.info("rollback sub-fonts-dir to initial value")
	else
		mp.set_property("sub-fonts-dir", fonts_dir)
		fonts_dir_cur = fonts_dir
		mp.msg.info("using `" .. fonts_dir .. "` as sub-fonts-dir")
	end
end

mp.register_event("start-file", update_fonts_dir)
