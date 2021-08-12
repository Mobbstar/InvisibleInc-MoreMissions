build_options = {} -- populated by builder.exe with the command line args.

local TF = { BC1 = 0, BC2 = 1, BC3 = 2, PVRTC_4BPP_RGBA = 3, PVRTC_4BPP_RGB = 4, PVRTC_2BPP_RGBA = 5, PVRTC_2BPP_RGB = 6, RGBA8 = 7, BGRA8 = 8 }
local AtlasStyle = { Decreasing = 0, Increasing = 1, Random = 2 }

local MaxPackageSize = 1024 * 1024 * 1024	--bytes
local MaxTextureWidth = 4096 --2048
local MaxTextureHeight = 4096 --2048

function CreateOptionsTBL( textureformat, quality, premul, underpaint, mipmap )
	local tbl =
	{
		platform = build_options.platform,			--used internally
		quality = quality,							--not used
		premul = premul,							--controls if we pre-multiply by the alpha channel
		underpaint = underpaint and not premul,		--controls if we underpaint around alpha edges, disabled if pre-multiplying is enabled
		genmipmap = mipmap,							--generate mipmaps
		textureformat = textureformat,				--texture format when atlas not created
		twidth = MaxTextureWidth,					--max texture width when not atlasing (any texture larger will be shrunk)
		theight = MaxTextureHeight,					--max texture height when not atlasing
		--debug_atlas = "c:/atlases",				--currently not implemented as of going to nvtt for BC[N] compression
	}
	return tbl
end

function PackageFolder( package, path, recursive, filterfn )
	local filepaths = {}
	package:ListFiles( path, filepaths, recursive )
	for _,srcpath in ipairs( filepaths ) do
		if not filterfn or filterfn(srcpath) then
			dstpath = srcpath
			package:LoadResource( srcpath, dstpath )
		end
	end
	return package
end

function PackageExample()



local options = CreateOptionsTBL( TF.RGBA8, 1.0, true, true, false )

-- IMAGES
local package = Package:new( "gui", MaxPackageSize, options )
package:CreateAtlas( TF.BC3, MaxTextureWidth, MaxTextureHeight, AtlasStyle.Increasing ) 
PackageFolder( package, "./gui", true, function(srcpath)
	return string.find(srcpath, ".png", -4) ~= nil
end )
package:Save( build_options.outputpath, "gui.kwad" )

-- AUDIO
-- package = Package:new( "sounds", MaxPackageSize, options )
-- PackageFolder( package, "./sound", true, function(srcpath)
-- 	return string.find(srcpath, ".fev", -4) ~= nil
-- 		or string.find(srcpath, ".fsb", -4) ~= nil
-- end )
-- package:Save( build_options.outputpath, "sound.kwad" )

-- ANIMS
local package = Package:new( "moremissions_anims", MaxPackageSize, options )
PackageFolder( package, "./anims", true, function(srcpath)
	return string.find(srcpath, ".anim", -5) ~= nil
end )
package:Save( build_options.outputpath, "moremissions_anims.kwad" )



end


function run( )
	PackageExample()
end
