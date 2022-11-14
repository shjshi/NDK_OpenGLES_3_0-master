/**
 *
 * Created by 公众号：字节流动 on 2021/10/12.
 * https://github.com/githubhaohao/NDK_OpenGLES_3_0
 * 最新文章首发于公众号：字节流动，有疑问或者技术交流可以添加微信 Byte-Flow ,领取视频教程, 拉你进技术交流群
 *
 * */
#ifndef NDK_OPENGLES_3_0_RGB2I444SAMPLE_H
#define NDK_OPENGLES_3_0_RGB2I444SAMPLE_H


#include "GLSampleBase.h"
#include "ImageDef.h"

class RGB2I444Sample : public GLSampleBase
{
public:
	RGB2I444Sample();

	virtual ~RGB2I444Sample();

	virtual void LoadImage(NativeImage *pImage);

	virtual void Init();
	virtual void Draw(int screenW, int screenH);

	virtual void Destroy();

	bool CreateFrameBufferObj();

private:
	GLuint m_ImageTextureId;
	GLuint m_FboTextureId;
	GLuint m_FboId;
	GLuint m_VaoIds[2] = {GL_NONE};
	GLuint m_VboIds[4] = {GL_NONE};
	GLint m_SamplerLoc;
	NativeImage m_RenderImage;
	GLuint m_FboProgramObj;
	GLuint m_FboVertexShader;
	GLuint m_FboFragmentShader;
	GLint m_FboSamplerLoc;
	//GLuint m_YuyvWidth;

};


#endif //NDK_OPENGLES_3_0_RGB2I444SAMPLE_H
