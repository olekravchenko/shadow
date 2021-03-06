(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



BeginPackage["shadow`"];


shadow::usage="shadow[object, mask, padding]";


Begin["`Private`"];


Options[shadow]={"blur"->10,"offset"->{5,-5},"color"->0.3,"outline"->False,"highlight"->False};


shadow[ob_,mask_,pad_Integer:0,OptionsPattern[]]:=
Module[{i,dims,m,b,x,y,padding,shad,shadcol,object,result,hi,bkg},
b=OptionValue["blur"];
{x,y}=OptionValue["offset"];
hi=OptionValue["highlight"];If[TrueQ[hi],hi={1,1.5}];
i=ImagePad[toimage[ob],pad,Padding->Automatic];
dims=ImageDimensions[i];
{m,bkg}=preprocessGraphicsMask[mask];
m=createMask[m,dims];
If[hi=!=False,i=highlight[i,m,{x,y},hi]];
If[OptionValue["outline"],i=outline[i,m]];
padding=b+(#-Min[#])&/@{{x,0},{y,0}};
shad=ImagePad[m,padding,Padding->Black]~Blur~b;
shadcol=colorimage[tocolor[OptionValue["color"]],ImageDimensions[shad]];
shad=SetAlphaChannel[shadcol,shad];
object=ImagePad[SetAlphaChannel[i,m],Reverse/@padding,Padding->RGBColor[0,0,0,0]];
result=iComp[shad,object];
If[bkg=!=0,
result=iComp[ImagePad[rastersize[bkg,dims],Reverse/@padding,Padding->Automatic],result]];
ImagePad[result,Clip[8-BorderDimensions[result,0],{-Infinity,0}],Padding->Automatic]]


anycolor=_GrayLevel|_Hue|_RGBColor|_CMYKColor;


tocolor[col_?NumberQ]:=tocolor[GrayLevel[col]]
tocolor[col:anycolor]:=ColorConvert[col,"RGB"]
tocolor[notcol_]:=Black


colorimage[col_,dims_]:=ImageResize[Image[{{{##}}}],dims]&@@col


toimage[ob:(_Image)]:=ob
toimage[ob:anycolor]:=colorimage[tocolor[ob],{360,360}]
toimage[ob_]:=Rasterize[ob]


preprocessGraphicsMask[mask:Graphics[prims_,opts__/;!FreeQ[{opts},Axes|Frame|GridLines]]]:=
{Show[mask,AxesStyle->Opacity[0],FrameStyle->Opacity[0],GridLinesStyle->Opacity[0],Background->None],Graphics[{},opts]}
preprocessGraphicsMask[mask_]:={mask,0}


createMask[mask_,dims_]:=ColorNegate[icreateMask[mask,dims]~ColorConvert~"Grayscale"]
icreateMask[mask_Image,dims_]:=resizeAR[mask,dims]
icreateMask[mask_Graphics,dims_]:=rastersize[blacken@mask,dims]
icreateMask[mask_,dims_]:=resizeAR[Rasterize[blacken@mask],dims]
icreateMask[r_Integer,{w_,h_}]:=Module[{rr=Floor@Min[2r,w-1,h-1]},
icreateMask[ColorNegate[Image[ConstantArray[1,{2h-2rr,2w-2rr}]]~ImagePad~rr~ImageConvolve~DiskMatrix[rr]],{w,h}]]
icreateMask[{s_String,amp_:1},dims_]:=tornpage[dims,s,amp]


(* equivalent to Rasterize[expr, ImageSize \[Rule] dims] but uses correct StyleSheet *)
rastersize[expr_,dims_]:=Rasterize[Show[expr,ImageSize->dims]]


resizeAR[x_,{w_,h_}]:=ImageCrop[ImageResize[x,{{w},{h}}],{w,h},Padding->Automatic]


blacken[g_]:=g/.anycolor->Black


tornpage[{w_,h_},edges_,amp_]:=
Module[{left,right,bottom,top,page},
left=If[StringFreeQ[edges,"L"],{{0,h},{0,0}},Reverse/@tear[h,amp]];
right=If[StringFreeQ[edges,"R"],{{w,0},{w,h}},Reverse[#+{0,w}]&/@tear[h,amp]];
bottom=If[StringFreeQ[edges,"B"],{{0,0},{w,0}},tear[w,amp]];
top=If[StringFreeQ[edges,"T"],{{w,h},{0,h}},(#+{0,h})&/@Reverse[tear[w,amp]]];
page=Graphics[Polygon[Join[bottom,right,top,left]],PlotRangePadding->0,ImagePadding->0,AspectRatio->h/w];
ImagePad[Rasterize[page,ImageSize->2+{w,h}],-1]]


tear[w_,amp_]:=Module[{a,b},
a=0.1Sqrt[w]amp Accumulate[RandomReal[{-1,1},{w}]];
b=a-Range[#1,#2,(#2-#1)/(w-1)]&[First@a,Last@a];
Transpose[{Range[0.,w,w/(w-1)],b}]]


highlight[i_,m_,{x_,y_},{s_,a_}]:=Module[{th,X,Y,hi},
th=If[x==0&&y==0,-Pi/4,ArcTan[x,y]];
{X,Y}=GaussianFilter[ImageData[m],{5s,s}, #]&/@{{1,0},{0,1}};
hi=a (Rescale[-X Sin[th]+Y Cos[th]]-0.5);
(* reduce shadows by 1/2 *)hi=hi(0.75 +0.25 Sign[hi]);
ImageAdd[i,Image[hi]]]


outline[i_,m_]:=ImageMultiply[i,ColorNegate[m~ImagePad~1~GradientFilter~1~ImagePad~-1]]


ic[a_,b_]:=Rasterize[Overlay[{a,b}],"Image",Background->None]


iComp=If[$VersionNumber>=10,ic,ImageCompose]


End[];


EndPackage[];
