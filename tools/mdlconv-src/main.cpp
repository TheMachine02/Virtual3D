#include <climits>
#include <cstdlib>
#include <string>
#include <string.h>
#include <ios>
#include <iostream>
#include <fstream>

#include <vector>
#include "glm/glm.hpp"

#define TEXTURE 1
#define NORMAL  2
#define COLOR   4
#define BOUNDING_BOX  8
#define SEPARATE    16
#define FACE_NORMAL 32

using namespace std;
using namespace glm;

bool loadOBJ(const char * path,unsigned short option);
ivec2 MapUV(vec2 textcoord,ivec2 texsize);
ivec3 MapNormal(vec3 n1,vec3 n2, vec3 n3);
ivec2 mapUV256(vec2 textcoord);
unsigned int convColor(float r, float g,float b);
//unsigned short rgb8to256(float r,float g, float b);
vector <vec3> getBoundingBox(vector <vec3> stream);
vector <string> processFace(string s);

struct material
{
    unsigned short color;
    char name[256];
    ivec2 texsize;
    int texID;
};
typedef struct material material;


int main(int argc, char* argv[])
{
///   arg = name
///   arg = -T : texture
///   arg = -N : normal
///   arg = -C : colors
    const char* path=NULL;
    unsigned short option=0;

    if(argc<2)
    {
        ///print the usage
        printf("Options : \n");
        printf("-t : output triangle texture uv\n");
        printf("-n : output vertex normal\n");
        printf("-c : output material color\n");
        printf("-b : output bounding box\n");
        printf("-s : output different files for vertex and index");
        return false;
    }

    int arg=0;

    while(arg<argc)
    {
        if(argv[arg][0]=='-'||argv[arg][0]=='/')
        {
            switch(toupper(argv[arg][1]))
            {
            case 'T':
                option=option|TEXTURE;
                break;
            case 'N':
                option=option|NORMAL;
                break;
            case 'C':
                option=option|COLOR;
                break;
            case 'B':
                option=option|BOUNDING_BOX;
                break;
            case 'S':
                option=option|SEPARATE;
                break;
            case 'X':
                option=option|FACE_NORMAL;
                break;
            default:
                printf("Unrecognized argument %s\n",argv[arg]);
            }
        }
        else
        {
            path=argv[arg];
        }
        arg++;
    }

    if(path==NULL)
    {
        printf("No file has been set\n");
        return false;
    }

    loadOBJ(path,option);
}

bool loadOBJ(const char * path, unsigned short option)
{
    ifstream in(path,std::ios::in);
    if (!in)
    {
        //cerr << "Cannot open " << path << endl;
        printf("Cannot open %s \n",path);
        exit(EXIT_FAILURE);
    }


    string line;

    vector <vec3> vertexTable;
    vector <vec2> textTable;
    vector <vec3> normalTable;
    vector <vec3> vertexNormalTable;
    vector <unsigned int> indexTable;
    vector <material> materialTable;
    vector <string> textureTable;

    material usemat;
    vec3 vertex;
    vec2 textCoord;
    vec3 normal;
  //  unsigned int index[9];
    char materialFile[256];
    char materialName[256];
    unsigned int indexMaterial=0;
    unsigned int i=0;

    while (std::getline(in, line))
    {

        if(line[0]=='v')
        {
            if(line[1]==' ')
            {
                sscanf(line.c_str(),"v %f %f %f",&vertex[0],&vertex[1],&vertex[2]);
                vertexTable.push_back(vertex);

            }
            else if(line[1]=='t'&&(option&TEXTURE))
            {
                sscanf(line.c_str(),"vt %f %f",&textCoord[0],&textCoord[1]);
                textTable.push_back(textCoord);

            }
            else if (line[1]=='n'&&(option&NORMAL))
            {
                sscanf(line.c_str(),"vn %f %f %f",&normal[0],&normal[1],&normal[2]);
                normalTable.push_back(normal);

            }
        }
        else if(line[0]=='f')
        {
            int i;
            //this is a face line, read index, we will write them later.
            //sscanf(line.c_str(),"f %d/%d/%d %d/%d/%d %d/%d/%d",&index[0],&index[1],&index[2],&index[3],&index[4],&index[5],&index[6],&index[7],&index[8]);

            vector<string> data=processFace(line);
            int datasize=(int)data.size()/3;
            if(datasize>3)
            {
                printf("Model contains quads, please triangulate before using mdlconv");
                exit(EXIT_FAILURE);
            }

            indexTable.push_back(indexMaterial);
            for(i=0;i<3;i++)
            {
                indexTable.push_back(strtol(data[i*3].c_str(),NULL,10)-1);
                indexTable.push_back(strtol(data[i*3+1].c_str(),NULL,10)-1);
                indexTable.push_back(strtol(data[i*3+2].c_str(),NULL,10)-1);
            }


            /*for(i=0; i<9; i++)
                indexTable.push_back(index[i]-1);*/
        }
        else if(strstr(line.c_str(),"mtllib")!=NULL)
        {
            //load the material file
            sscanf(line.c_str(),"mtllib %256s",(char*)&materialFile);
            printf("Loading dependencies : %s\n",materialFile);

            string directory=path;
            i=directory.find_last_of("/\\");
            if(i==string::npos) i=-1;

            ifstream mat(directory.substr(0,i+1).append(materialFile).c_str(),std::ios::in);
            if(!mat)
            {
                printf("Cannot open %s\n",materialFile);
                exit(EXIT_FAILURE);
            }
            /// read the file and push materials;
            string mline;
            usemat.color=255;
            strcpy(usemat.name,"DEFAULT_CONVERTER_MAT\0");
            usemat.texsize=ivec2(256,256);
            usemat.texID=0;

            while(getline(mat,mline))
            {
                if(mline.find("newmtl")!=std::string::npos)
                {
                    materialTable.push_back(usemat);
                    sscanf(mline.c_str(), "newmtl %256s",(char*)&materialName);
                    strcpy(usemat.name,materialName);
                }

                else if(mline.find("map_Kd")!=std::string::npos)
                {
                    sscanf(mline.c_str(),"map_Kd %s",(char*)&materialName);


                    string directory=path;
                    i=directory.find_last_of("/\\");
                    if(i==string::npos) i=-1;
                    string texturePath=directory.substr(0,i+1).append(materialName);

                    //if(!texture.ReadFromFile(texturePath.c_str()))
                    //{
                        usemat.texsize=ivec2(256,256);
                        //printf("Couldn't read file %s, using default 64x64 texture size\n",texturePath.c_str());
                    //}
                    //else
                    //{
                    //    usemat.texsize[0]=texture.TellWidth();
                    //    usemat.texsize[1]=texture.TellHeight();
                    //}
                        // find texture id

                        for(i=0; i<textureTable.size(); i++)
                        {
                            if(strcmp(textureTable[i].c_str(),materialName)==0)
                            {
                                usemat.texID=i;
                                break;
                            }
                        }
                        if(i==textureTable.size())
                        {
                            textureTable.push_back(materialName);
                            usemat.texID=i;
                        }
                }
                else if(mline.find("Kd")!=std::string::npos)
                {
                    float r,g,b;
                    sscanf(mline.c_str(),"Kd %f %f %f",&r,&g,&b);
                    usemat.color=convColor(r,g,b)
;
                }
            }
            materialTable.push_back(usemat);

        }
        else if(strstr(line.c_str(),"usemtl")!=NULL)
        {
            sscanf(line.c_str(),"usemtl %256s",(char*)&materialName);
            printf("Loading material : %s",materialName);
            indexMaterial=0;
            for(i=0; i<materialTable.size(); i++)
            {
                usemat=materialTable[i];
                if(strcmp(usemat.name,materialName)==0)
                {
                    indexMaterial=i;
                    break;
                }
            }
            if(i==materialTable.size())
            {
                printf("\nMaterial %s not found, using default\n",materialName);
            }else
            {
                printf(", index: %d\n", i);
            }


        }


    }


    string newfile=path;
    i=newfile.find('.');
    string newpath=newfile.substr(0,i).append("0.inc");

    ofstream out(newpath.c_str(),std::ios::out);
    if(!out)
    {
        cerr << "Cannot open " << newpath.c_str() << endl;
        exit(EXIT_FAILURE);
    }

    //compute vertex normal
    unsigned int j;
    vertexNormalTable.reserve(vertexTable.size());
    for(i=0;i<indexTable.size()/10;i++)
    {
        for(j=0;j<3;j++)
            vertexNormalTable[indexTable[i*10+1+(j*3)]]+=normalize(normalTable[indexTable[i*10+3]]+normalTable[indexTable[i*10+6]]+normalTable[indexTable[i*10+9]]);
    }
    for(i=0;i<vertexTable.size();i++)
        vertexNormalTable[i]=normalize(vertexNormalTable[i]);

  /*  out << "#include \"IrisModel.inc\"" << '\n';
    out << ".dl INDEX_OFFSET" << '\n' << ".dl " << indexTable.size()/10 << '\n';
    out << ".dl VERTEX_OFFSET" << '\n' << ".dl " << vertexTable.size() << '\n';

    out << "VERTEX_OFFSET:" << '\n';*/

    out << "#include \"vxModel.inc\"" << '\n';
    out << "VERTEX_STREAM:" << '\n';
    out << ".dl " << (vertexTable.size()*256)+option << '\n';

    if(option&BOUNDING_BOX)
    {
        vector <vec3> boundbox=getBoundingBox(vertexTable);
        for(i=0;i<boundbox.size();i++)
        {
            out << ".dw ";
            out << round(boundbox[i][0]*256.0) << ",";
            out << round(boundbox[i][1]*256.0) << ",";
            out << round(boundbox[i][2]*-256.0) << '\n';
        }
    }

    for(i=0; i<vertexTable.size(); i++)
    {
        out << ".v ";
        out << round(vertexTable[i][0]*256.0) << ",";
        out << round(vertexTable[i][1]*256.0) << ",";
        out << round(vertexTable[i][2]*-256.0) << '\n';
        if(option&NORMAL)
        {
            out << ".db ";
            out << round(vertexNormalTable[i][0]*64.0) << ",";
            out << round(vertexNormalTable[i][1]*64.0) << ",";
            out << round(vertexNormalTable[i][2]*-64.0) << '\n';
        }
    }

    if(option&SEPARATE)
    {

    newfile=path;
    i=newfile.find('.');
    string newpath2=newfile.substr(0,i).append("1.inc");

    out.close();
    out.open(newpath2.c_str(),std::ios::out);
    if(!out)
    {
        cerr << "Cannot open " << newpath2.c_str() << endl;
        exit(EXIT_FAILURE);
    }
    out << "#include \"vxModel.inc\"" << '\n';

    }


    out << "INDEX_STREAM:" << '\n';
    out << ".dl " << (indexTable.size()/10)*256+option << '\n';

    for(i=0; i<indexTable.size()/10; i++)
    {
        usemat=materialTable[indexTable[i*10]];
        out << ".f " << indexTable[i*10+1] << "," << indexTable[i*10+4] << "," << indexTable[i*10+7] << '\n';

        if(option&FACE_NORMAL)
        {
            vec3 edge0;
            vec3 edge1;

            edge0 = vertexTable[indexTable[i*10+4]] - vertexTable[indexTable[i*10+1]];
            edge1 = vertexTable[indexTable[i*10+7]] - vertexTable[indexTable[i*10+1]];
            vec3 norm=normalize(cross(edge0,edge1));

            vec3 cst(64.0,64.0,-64.0);
            vec3 cst2(256.0*77.0/64.0,256.0*102.0/64.0,-256.0);
         //   vec3 norm = normalize(normalTable[indexTable[i*10+3]]+normalTable[indexTable[i*10+6]]+normalTable[indexTable[i*10+9]]);

            norm = norm * cst;
            vec3 vertex = vertexTable[indexTable[i*10+1]] * cst2;

            out << ".db " << round(norm[0]) << ',' << round(norm[1]) << ',' << round(norm[2]) << '\n';
            out << ".dl " << round(dot(norm,vertex )) << '\n';
            // n*(p-v)  n (64) *p (256)

        }

        if(option&COLOR)
        {
            out << ".db " << usemat.color << '\n';
        }

        if(option&TEXTURE)
        {
            //ivec2 texsize;
            //texsize=usemat.texsize;
            out << ".db " << usemat.texID << '\n';
            ivec2 text;
            text=mapUV256(textTable[indexTable[i*10+2]]);
            out << ".db " << text[0] << "," << text[1] << '\n';
            text=mapUV256(textTable[indexTable[i*10+5]]);
            out << ".db " << text[0] << ',' << text[1] << '\n';
            text=mapUV256(textTable[indexTable[i*10+8]]);
            out << ".db " << text[0] << ',' << text[1] << '\n';
        }

    }
    out.close();
    return true;

}

//unsigned short rgb8to256(float r,float g, float b)
//{
//    return (r*7/255<<5)|(b*3/255<<3)|(g*7/255);
//  return ((int)(r*7.0)<<5)|((int)(b*3.0)<<3)|((int)(g*7.0));
//}

unsigned int convColor(float r,float g, float b)
{

    return (std::min((unsigned int)(r*255.0)+4,(unsigned)255)>>5)<<5 | ((std::min((unsigned int)(b*255.0)+8,(unsigned)255)>>6)<<3) | (std::min((unsigned int)(g*255.0)+4,(unsigned)255)>>5);
}

/*ivec3 MapNormal(vec3 n1,vec3 n2, vec3 n3)
{
    vec3 tmp;
    ivec3 out;

    tmp[0]=(n1[0]+n2[0]+n3[0])/3.0;
    tmp[1]=(n1[1]+n2[1]+n3[1])/3.0;
    tmp[2]=-(n1[2]+n2[2]+n3[2])/3.0;
    tmp=normalize(tmp);

    out[0]=(int)round(tmp[0]*64.0);
    out[1]=(int)round(tmp[1]*64.0);
    out[2]=(int)round(tmp[2]*64.0);
    return out;
}*/

ivec2 MapUV(vec2 textcoord,ivec2 texsize)
{
    /*
    ivec2 texint;

    unsigned int t;
    t=round(texcoord[0]*texsize[0]);
    texint[0]=t%(texsize[0]+1);

    t=round((1.0-texcoord[1])*texsize[1]);
    texint[1]=t%(texsize[1]+1);
    */

//    texint[0]=clamp((int)(clamp(texcoord[0],0.0f,1.0f)*256),0,255);
//    texint[1]=clamp((int)(clamp(1.0f-texcoord[1],0.0f,1.0f)*256),0,255);


   // texint[0]=abs((int)round(texcoord[0]*texsize[0])%(texsize[0]+1));
   // texint[1]=abs((int)round((1.0-texcoord[1])*texsize[1])%(texsize[1]+1));

    //texint[0]=(int)(texcoord[0]*127.0)%128;
    //texint[1]=(int)((1.0-texcoord[1])*127.0)%128;
/*
    ivec2 texint;
    texint.x=(int)clamp(clamp(texcoord.x,0.0f,1.0f)*texsize.x,0.0f,255.0f);
    texint.y=(int)clamp(clamp(1.0f-texcoord.y,0.0f,1.0f)*texsize.y,0.0f,255.0f);
*/

    ivec2 texture;
    texture.x=(int)clamp(textcoord.x*256.0f,0.0f,255.0f);
    texture.y=(int)clamp((1.0f-textcoord.y)*256.0f,0.0f,255.0f);
    return texture;
}

ivec2 mapUV256(vec2 textcoord)
{
    ivec2 texture;
    texture.x=(int)clamp(textcoord.x*256.0f,0.0f,255.0f);
    texture.y=(int)clamp((1.0f-textcoord.y)*256.0f,0.0f,255.0f);
    return texture;
}


vector <vec3> getBoundingBox(vector <vec3> stream)
{
    vector <vec3> box;
    vec3 tmp;
    vec3 vmax;
    vec3 vmin;
    unsigned int i;
    for(i=0;i<stream.size();i++)
    {
        vmax[0]=std::max(stream[i][0],vmax[0]);
        vmax[1]=std::max(stream[i][1],vmax[1]);
        vmax[2]=std::max(stream[i][2],vmax[2]);

        vmin[0]=std::min(stream[i][0],vmin[0]);
        vmin[1]=std::min(stream[i][1],vmin[1]);
        vmin[2]=std::min(stream[i][2],vmin[2]);
    }

    /*
    max,max  ---- min,max
    |                |
    |                |
    |                |
    |                |
    max, min ----- min,min
    */

    tmp=vmax;
    box.push_back(tmp);
    tmp[0]=vmin[0];
    box.push_back(tmp);
    tmp[2]=vmin[2];
    box.push_back(tmp);
    tmp[0]=vmax[0];
    box.push_back(tmp);

    tmp=vmax;
    tmp[1]=vmin[1];
    box.push_back(tmp);
    tmp[0]=vmin[0];
    box.push_back(tmp);
    tmp[2]=vmin[2];
    box.push_back(tmp);
    tmp[0]=vmax[0];
    box.push_back(tmp);

    return box;
}

vector <string> processFace(string s)
{
    //Remplace "//" par "/1/".
    string s1="";
    for(unsigned int i=0;i<s.size();i++)
    {
        if(i<s.size()-1&&s[i]=='/'&&s[i+1]=='/')
        {
            s1+="/1/";
            i++;
        }
        else
            s1+=s[i];
    }
    //Remplace les '/' par des espaces.
    string ret="";
    for(unsigned int i=0;i<s1.size();i++)
    {
        if(s1[i]=='/')
            ret+=' ';
        else
            ret+=s1[i];
    }

    vector<string> ret0;
    s1="";
    ret=ret.substr(2);
    for(unsigned int i=0;i<ret.size();i++)
    {
        if(ret[i]==' '||i==ret.size()-1)
        {
            if(i==ret.size()-1)
                s1+=ret[i];
            ret0.push_back(s1);
            s1="";
        }
        else
            s1+=ret[i];
    }

    return ret0;
}
