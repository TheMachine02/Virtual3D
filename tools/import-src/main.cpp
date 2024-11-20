#include <climits>
#include <cstdlib>
#include <string>
#include <string.h>
#include <ios>
#include <iostream>
#include <fstream>

#include <vector>
#include "glm/glm/glm.hpp"

#define TEXTURE 1
#define NORMAL  2
#define COLOR   4
#define BOUNDING_BOX  8
#define SEPARATE    16
#define FACE_NORMAL 32

using namespace std;
using namespace glm;

bool load_obj(const char * path, const char* name, unsigned short option);
ivec2 map_texture(vec2 textcoord);
unsigned short rgb8to256(float r, float g,float b);
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


int sgn(double x)
{
	if (x > 0) return 0;
	if (x < 0) return 1;
	return 0;
}


int main(int argc, char* argv[])
{
///   arg = name
///   arg = -T : texture
///   arg = -N : normal
///   arg = -C : colors
    const char* path=NULL;
    const char* name=NULL;
    unsigned short option=0;

    if(argc<2)
    {
        ///print the usage
        printf("Options : \n");
        printf("-t : output triangle texture uv\n");
        printf("-n : output vertex normal\n");
        printf("-c : output material color\n");
        printf("-b : output bounding box\n");
        printf("-s : output different files for vertex and index\n");
	printf("-x : output face normal\n");
        printf("-o= : define an Output file for fasmg compilation or ignore the fasmg header if not set");
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
	    case 'O':
		    name = argv[arg];
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
    if(name==NULL){
        printf("No output file has been set\n");
    }
    
    load_obj(path,name,option);
}

bool load_obj(const char * path, const char * name, unsigned short option)
{
    ifstream in(path,std::ios::in);
    if (!in)
    {
        //cerr << "Cannot open " << path << endl;
        printf("Cannot open %s \n",path);
        exit(EXIT_FAILURE);
    }


    string line;
    string o_name;
    vector <vec3> vertexTable;
    vector <vec2> textTable;
    vector <vec3> normalTable;
    vector <vec3> vertexNormalTable;
    vector <unsigned int> face_index;
    vector <material> materialTable;
    vector <string> textureTable;
    
	vector <vec3> face_normal;
	vector <vec3> vertex_normal;
	vector <float> vertex_cangle;
	vector <float> vertex_coffset;
    unsigned int face_count=0;
    unsigned int vertex_count=0;
    
    material current_material;
  //  unsigned int index[9];
    char materialFile[256];
    char materialName[256];
    unsigned int indexMaterial=0;
    unsigned int i=0;

    vec3 vertex;
    vec2 texcoord;
    vec3 normal;
	// world scale to have correspondance between the blender world and the library world
    const vec3 scale(1.0f, 1.0f, -1.0f);
    
    while (std::getline(in, line))
    {

        if(line[0]=='v')
        {
            if(line[1]==' ')
            {
                sscanf(line.c_str(),"v %f %f %f",&vertex[0],&vertex[1],&vertex[2]);
				
                vertexTable.push_back(vertex*scale);

            }
            else if(line[1]=='t'&&(option&TEXTURE))
            {
                sscanf(line.c_str(),"vt %f %f",&texcoord[0],&texcoord[1]);
                textTable.push_back(texcoord);

            }
            else if (line[1]=='n'&&(option&NORMAL))
            {
                sscanf(line.c_str(),"vn %f %f %f",&normal[0],&normal[1],&normal[2]);
                normalTable.push_back(normal*scale);

            }
        }
        else if(line[0]=='f')
        {
            vector<string> data=processFace(line);
            int datasize=(int)data.size()/3;
            if(datasize>3)
            {
                printf("Model contains quads, please triangulate before using import");
                exit(EXIT_FAILURE);
            }

            face_index.push_back(indexMaterial);
            for(i=0;i<3;i++)
            {
                face_index.push_back(strtol(data[i*3].c_str(),NULL,10)-1);
                face_index.push_back(strtol(data[i*3+1].c_str(),NULL,10)-1);
                face_index.push_back(strtol(data[i*3+2].c_str(),NULL,10)-1);
            }


            /*for(i=0; i<9; i++)
                face_index.push_back(index[i]-1);*/
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
            current_material.color=255;
            strcpy(current_material.name,"DEFAULT_CONVERTER_MAT\0");
            current_material.texsize=ivec2(256,256);
            current_material.texID=0;

            while(getline(mat,mline))
            {
                if(mline.find("newmtl")!=std::string::npos)
                {
                    materialTable.push_back(current_material);
                    sscanf(mline.c_str(), "newmtl %256s",(char*)&materialName);
                    strcpy(current_material.name,materialName);
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
                        current_material.texsize=ivec2(256,256);
                        //printf("Couldn't read file %s, using default 64x64 texture size\n",texturePath.c_str());
                    //}
                    //else
                    //{
                    //    current_material.texsize[0]=texture.TellWidth();
                    //    current_material.texsize[1]=texture.TellHeight();
                    //}
                        // find texture id

                        for(i=0; i<textureTable.size(); i++)
                        {
                            if(strcmp(textureTable[i].c_str(),materialName)==0)
                            {
                                current_material.texID=i;
                                break;
                            }
                        }
                        if(i==textureTable.size())
                        {
                            textureTable.push_back(materialName);
                            current_material.texID=i;
                        }
                }
                else if(mline.find("Kd")!=std::string::npos)
                {
                    float r,g,b;
                    sscanf(mline.c_str(),"Kd %f %f %f",&r,&g,&b);
                    current_material.color=rgb8to256(r,g,b)
;
                }
            }
            materialTable.push_back(current_material);

        }
        else if(strstr(line.c_str(),"usemtl")!=NULL)
        {
            sscanf(line.c_str(),"usemtl %256s",(char*)&materialName);
            printf("Loading material : %s",materialName);
            indexMaterial=0;
            for(i=0; i<materialTable.size(); i++)
            {
                current_material=materialTable[i];
                if(strcmp(current_material.name,materialName)==0)
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
    for(i=0;i<face_index.size()/10;i++)
    {
        for(j=0;j<3;j++)
            vertexNormalTable[face_index[i*10+1+(j*3)]]+=normalize(normalTable[face_index[i*10+3]]+normalTable[face_index[i*10+6]]+normalTable[face_index[i*10+9]]);
    }
    for(i=0;i<vertexTable.size();i++)
        vertexNormalTable[i]=normalize(vertexNormalTable[i]);
    
    
//     face_count=face_index.size()/10;
//     vertex_count=vertexTable.size();
//     
//     //compute normal
//     vertex_normal.reserve(vertex_count);
// 	vertex_cangle.reserve(vertex_count);
// 	vertex_coffset.reserve(vertex_count);
//     face_normal.reserve(face_count);
//     
// 	// face_index is material_id, index, index_tex, index_norm
// 	
//     unsigned int v_index0, v_index1, v_index2, n_index;
//     
//     for(i=0;i<face_count;i++)
//     {
// 		v_index0 = face_index[i*10+3];
// 		v_index1 = face_index[i*10+6];
// 	    v_index2 = face_index[i*10+9];
// 		face_normal[i]= normalize( normalTable[v_index0] + normalTable[v_index1] + normalTable[v_index2]);
// 		
// 		// add this face normal to the vertex's normal
// 		
// 		for(j=0;j<3;j++)
// 		{
// 			n_index = face_index[i*10+j*3+1];
// 			vertex_normal[n_index] = normalize(face_normal[i]+vertex_normal[n_index]);
// 		}
//     }    
//     
//     // now find the vertex cone angle from face normal and vertex normal (maximal absolute angle)
//     for(i=0;i<face_count;i++)
// 	{
// 		vec3 f_normal = face_normal[i];
// 		
// 		for(j=0;j<3;j++)
// 		{
// 			n_index = face_index[i*10+j*3+1];
// 			vec3 v_normal = vertex_normal[n_index];
// 			vertex_cangle[n_index]=std::max(std::abs(acos(dot(v_normal,f_normal))),vertex_cangle[n_index]);
// 		}
// 	}
 //    // find the associated vertex normal offset, normal calculation    
 //    for(i=0;i<vertex_count;i++)
	// {
	// 	vec3 v_position = normalize(vertexTable[i]);
	// 	vec3 v_normal = vertex_normal[i];
	// 	vertex_coffset[i] = acos(dot(v_position, v_normal));
	// }

// coffset is the angle offset for the (p-v)*n :: p*n componnent
// cangle is the cone angle

// in vertex shader we'll compute :
// (acos(dot(normal,normalize(view)))-coffset) +- cangle (based on the angle : always toward 0)
        if(name!=NULL)
        {  

            out << "include \"include/fasmg/ez80.inc\"\n";
            out << "include \"include/fasmg/tiformat.inc\"\n";
        
            out << "format ti archived appvar \'";
            o_name = name;
            o_name = o_name.substr(3);
            out << o_name;
            out << "V" << "\'\n";
        }
        
        out << "define nan 0\n";
        out << "define inf 0\n";

        
//    out << "include \"vxModel.inc\"" << '\n';
//    out << "VERTEX_STREAM:" << '\n';
    out << "db " << option << '\n';
    out << "dl " << vertexTable.size() << '\n';
	int sm=0;
    
    if(option&BOUNDING_BOX)
    {
        vector <vec3> boundbox=getBoundingBox(vertexTable);
        for(i=0;i<boundbox.size();i++)
        {
//             out << "dw ";
//             out << round(boundbox[i][0]*256.0) << ",";
//             out << round(boundbox[i][1]*256.0) << ",";
//             out << round(boundbox[i][2]*256.0) << '\n';
            sm = sgn(round(boundbox[i][0]*256.0)) << 7 | ( sgn(round(boundbox[i][1]*256.0)) << 6) | (sgn(round(boundbox[i][2]*256.0)) << 5);
            if((abs(round(boundbox[i][0]*256.0))<256) && (abs(round(boundbox[i][1]*256.0))<256) && (abs(round(boundbox[i][2]*256.0))<256)) {
                sm |= 16;    
            }
            out << "db "<< sm << "\n";
            out << "dw ";
            out << abs(round(boundbox[i][0]*256.0)) << ",";
            out << abs(round(boundbox[i][1]*256.0)) << ",";
            out << abs(round(boundbox[i][2]*256.0)) << '\n';
        
            if(option & NORMAL){
		out << "db 0,0,0\n";
            }
	}
    out << "; end marker\ndb 1\n";    //dw 0,0,0\ndb 0,0,0\n
    }

    for(i=0; i<vertexTable.size(); i++)
    {
        sm = sgn(round(vertexTable[i][0]*256.0)) << 7 | ( sgn(round(vertexTable[i][1]*256.0)) << 6) | (sgn(round(vertexTable[i][2]*256.0)) << 5);
	
	if((abs(round(vertexTable[i][0]*256.0))<256) && (abs(round(vertexTable[i][1]*256.0))<256) && (abs(round(vertexTable[i][2]*256.0))<256)) {
	    sm |= 16;    
	}
        out << "db "<< sm << "\n";
        out << "dw ";
        out << abs(round(vertexTable[i][0]*256.0)) << ",";
        out << abs(round(vertexTable[i][1]*256.0)) << ",";
        out << abs(round(vertexTable[i][2]*256.0)) << '\n';
        if(option & NORMAL){
            out << "db ";
            out << round(vertexNormalTable[i][0]*64.0) << ",";
            out << round(vertexNormalTable[i][1]*64.0) << ",";
            out << round(vertexNormalTable[i][2]*64.0) << '\n';
        }
    }
    out << "; end marker\ndb 1\n";    

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
        if(name!=NULL)
        {          
            out << "include \"include/fasmg/ez80.inc\"\n";
            out << "include \"include/fasmg/tiformat.inc\"\n";
            out << "format ti archived appvar \'" << o_name << "F" << "\'\n";
        }
        out << "define nan 0\n";
    }

 //   out << "INDEX_STREAM:" << '\n';
    out << "db " << option << '\n';
    out << "dl " << face_index.size()/10 << '\n';

    for(i=0; i<face_index.size()/10; i++)
    {
        current_material=materialTable[face_index[i*10]];
        out << "dl " << face_index[i*10+1] *16 << "," << face_index[i*10+4] *16 << "," << face_index[i*10+7] *16 << '\n';

//         if(option&FACE_NORMAL)
//        {
            vec3 edge0;
            vec3 edge1;

            edge0 = vertexTable[face_index[i*10+1]] - vertexTable[face_index[i*10+4]];
            edge1 = vertexTable[face_index[i*10+1]] - vertexTable[face_index[i*10+7]];
            vec3 norm=normalize(cross(edge0,edge1));
            vec3 cst(31.0,31.0,31.0);
            vec3 cst2(256.0,256.0,256.0);
            norm = norm * cst;
            vec3 vertex = vertexTable[face_index[i*10+1]] * cst2;
            out << "db " << ((int)round(norm[0]))*4 << ',' << ((int)round(norm[1])*4) << ',' << ((int)round(norm[2]))*4 << '\n';
            out << "dl " << -round(dot(norm,vertex)) << '\n';
            // n*(p-v)  n (64) *p (256)
//        }

        if(option&COLOR)
        {
            out << "db " << current_material.color << '\n';
        }

        if(option&TEXTURE)
        {
 //           out << "db " << current_material.texID << '\n';
            ivec2 text;
            text=map_texture(textTable[face_index[i*10+2]]);
            out << "db " << text[0] << "," << text[1] << '\n';
            text=map_texture(textTable[face_index[i*10+5]]);
            out << "db " << text[0] << ',' << text[1] << '\n';
            text=map_texture(textTable[face_index[i*10+8]]);
            out << "db " << text[0] << ',' << text[1] << '\n';
        }

        
    }
    out << "; end marker\ndb 1";
    
    out.close();
    return true;

}

//unsigned short rgb8to256(float r,float g, float b)
//{
//    return (r*7/255<<5)|(b*3/255<<3)|(g*7/255);
//  return ((int)(r*7.0)<<5)|((int)(b*3.0)<<3)|((int)(g*7.0));
//}

unsigned short rgb8to256(float r,float g, float b)
{

    return (std::min((unsigned int)(r*255.0)+4,(unsigned)255)>>5)<<5 | ((std::min((unsigned int)(b*255.0)+8,(unsigned)255)>>6)<<3) | (std::min((unsigned int)(g*255.0)+4,(unsigned)255)>>5);
}

ivec2 map_texture(vec2 texcoord)
{
    ivec2 texture;
    texture.x=(int)round(clamp(texcoord.x*256.0f,0.0f,255.0f));
    texture.y=(int)round(clamp((1.0f-texcoord.y)*256.0f,0.0f,255.0f));
    return texture;
}


vector <vec3> getBoundingBox(vector <vec3> stream)
{
    vector <vec3> box;
    vec3 tmp(0.0f,0.0f,0.0f);
    vec3 vmax(-FLT_MAX,-FLT_MAX,-FLT_MAX);
    vec3 vmin(FLT_MAX,FLT_MAX,FLT_MAX);
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
