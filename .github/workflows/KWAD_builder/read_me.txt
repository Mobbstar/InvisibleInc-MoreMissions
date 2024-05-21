Note:
	This is *NOT* an official tool, we won't be supporting it.
	Builder was stable for us; I know of only one crash, if you try to make a package with zero files.
	The version of builder included here is 64 bit.
	You can safely delete the int folder contents; it holds precompiled resources from previous builds which are only there to speed up future builds.

Formats: (I'm not actually checking if this is all correct)


KWAD									BYTES
	u32 : FOURCC('K','L','E','I')		4
	u32 : FOURCC('P','K','G','2')		4
	u32 : package size					4
	u32 : slab count 					4
	u32 : resource_count 				4
	resource_info[resource_count]		variable
	u32 : alias_count 					4
	alias_info[alias_count] 			variable
	slab : first resource slab 			variable

resource_info
	u32 : slab_idx						4
	u32 : size							4
	u32 : offset						4
	u32 : type							4

alias_info
	encodedstring : alias path			variable
	u32 : resource idx 					4

encodedstring
	u32 : len
	u8[ len + (4-len%4)%4 ]  : string contents padded to maintain DWORD alignment

SLAB
	u32 : FOURCC('K','L','E','I')		4
	u32 : FOURCC('S','L','B','1')		4
	resource[] : binary array of resources indexed via the resource_info.offset

resources*	--There are 8 types of resources that builder produces from the consumed files:
	SRF1	--This defines a surface typically BC3 or RGBA
	TEX1	--This defines a texture which points to a surface with a UV mapping
	MDL1	--This is a vertex buffer used by KleiAnim for builds
	ANM1	--This defines the animations of a KleiAnim
	BLD1	--This defines the builds of a KleiAnim
	XANM	--This was a partially implemented conversion of the ANM1 & BLD1 KleiAnims to a bezier spline form
	BLOB	--This is a binary blob, could be anything


SRF1
	u32 : FOURCC('K','L','E','I')		4
	u32 : FOURCC('S','R','F','1')		4
	u32 : resource size					4
	u32	: opengl types 					4
	u32 : opengl storage type 			4
	u32 : compressed 					4
	u32 : mip count 					4
	u32 : total size of all mips 		4
	mip_level: * 						variable
		u32 : level size				4
		u32 : level width 				4
		u32 : level height 				4
		u32 : zipped size 				4
		zip : zipped surface 			variable

TEX1
	u32 : FOURCC('K','L','E','I')		4
	u32 : FOURCC('T','E','X','1')		4
	u32 : resource size					4
	u32 : SRF1 idx 						4
	u32 : width 						4
	u32 : height 						4
	affine2d : uv transform 			24



I'll leave the rest of the formats as a exersize. This code, from the c++ source, should be tremendously helpful in your hacking.

//AnimDef
struct Instance
{
	const u32			m_SymbolHash;
	const u32			m_FolderHash;
	const u32			m_ParentHash;
	const u32			m_SymbolFrame;
	const u32			m_ParentTransformIdx;
	const u32			m_TransformIdx;
	const u32			m_CMIdx;
	const u32			m_CAIdx;
};
struct Frame
{
	const u32			m_EventIdx;
	const u32			m_EventCount;
	const u32			m_InstanceIdx;
	const u32			m_InstanceCount;
};
struct Anim
{
	const u32			m_NameHash;
	const char			m_NameStr[20];
	const u32			m_RootSymbolHash;
	const f32			m_FrameRate;
	const u32			m_FacingMask;
	const u32			m_FrameIdx;
	const u32			m_FrameCount;
};

u32					m_InstanceCount;
const Instance*		m_Instances;

u32					m_FrameCount;
const Frame*		m_Frames;

u32					m_EventCount;
const u32*			m_Events;

u32					m_AnimCount;
const Anim*			m_Anims;

u32					m_ColourCount;
const USColorVec*	m_Colours;

u32					m_TransformCount;
const USAffine3D*	m_Transforms;

u32					m_EventStringsSize;
const char*			m_EventStrings;

//AnimBld
struct SymbolFrame
{
	u32			m_ModelIdx;
	USAffine3D	m_Transform;
};
struct Symbol
{
	u32			m_SymbolHash;
	char		m_SymbolName[20];
	u32			m_FrameIdx;
	u32			m_FrameCount;
};

const Symbol*		m_Symbols;
u32					m_SymbolCount;

const SymbolFrame* m_SymbolFrames;
u32					m_SymbolFrameCount;