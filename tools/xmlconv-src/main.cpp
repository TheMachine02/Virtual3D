#include <climits>
#include <cstdlib>
#include <string>
#include <string.h>
#include <ios>
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <iterator>
#include "glm/glm/glm.hpp"

#define MAX_LINE_SIZE 16777216
#define TEXTURE     1
#define NORMAL      2
#define COLOR       4
#define BOUNDING_BOX  8
#define SEPARATE    16
#define MATRIX      64

using namespace std;
using namespace glm;
vector <mat4x4> applyMul(vector <mat4x4> right,vector <mat4x4> left);
void display_vector(const vector<int> &v);
ivec2 map_texture(vec2 textcoord);

int sgn(double x)
{
	if (x > 0) return 0;
	if (x < 0) return 1;
	return 0;
}

int main(int argc, char* argv[])
{
    const char* path=argv[1];

    mat4 mswap(1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1);
    double skip;
    int fstart=0;
    int fend=0;

    vec4 scale4(1,1,1,1);
    vec3 scale3(1,1,1);

    ifstream xml(path, std::ios::in);
    if (!xml)
    {
        printf("Cannot open %s \n",path);
        exit(EXIT_FAILURE);
    }
    printf("Converting %s\n", path);

    string line;
    vector <vec3> vertex;
    vector <vec2> texture;
    vector <vec3> normal;
    vector <ivec3> triangle;
    vector <pair <int, int> > link;
    vector <mat4> mbind;

    vector < vector <mat4x4> > matrixTable;

    int i;
    int bcount=0;

    for(i=0;i<256;i++)
    {
        matrixTable.push_back(mbind);
    }


    while(std::getline(xml, line))
    {

        if(line.find("<vertex>")!=string::npos)
        {
            //read the whole line of vertex \o/
            i=8;
            line=line.substr(i,line.size());
            while(line.find(" ")!=string::npos)
            {
                vec3 v;
                v[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                v[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());

                v[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());

                vertex.push_back(v);
            }
            continue;
        }

        if(line.find("<triangle>")!=string::npos)
        {
            //read the whole line of vertex \o/
            i=10;
            line=line.substr(i,line.size());
            while(line.find(" ")!=string::npos)
            {
                ivec3 v;
                v[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                v[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());

                v[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());

                triangle.push_back(v);

            }
            continue;
        }


        if(line.find("<texture>")!=string::npos)
        {
            i=9;
            line=line.substr(i,line.size());
            while(line.find(" ")!=string::npos)
            {
                vec2 t;
                t[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                t[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                texture.push_back(t);
            }
            continue;
        }

        if(line.find("<normal>")!=string::npos)
        {
            i=8;
            line=line.substr(i,line.size());
            while(line.find(" ")!=string::npos)
            {
                vec3 n;
                n[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                n[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                n[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                normal.push_back(n);
            }
            continue;
        }
        if(line.find("<bone")!=string::npos)
        {
            //<bone id=0>
            i=9;
            line=line.substr(i,line.size());
            double d=strtod(line.c_str(),NULL);
            int id=(int)d;
            if(d>255)
                exit(EXIT_FAILURE);

            line=line.substr(line.find(">")+1,line.size());
            bcount=std::max(bcount,id+1);

            while(line.find(" ")!=string::npos)
            {

                vec4 col0, col1, col2, col3;
                col0[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[0]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[0]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[1]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[1]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[2]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[2]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[3]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[3]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[3]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[3]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                mat4x4 m(col0,col1,col2,col3);

                matrixTable[id].push_back(m);
            }
            continue;
        }
        if(line.find("<link>")!=string::npos)
        {
            //read linking, bone : vertexid
            i=6;
            line=line.substr(i,line.size());
            while(line.find(" ")!=string::npos)
            {
                vec2 p;
                p[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                p[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                link.push_back(make_pair(p[0],p[1]));
            }

            // now we need to sort the list based on bone value.
            sort(link.begin(),link.end());

            continue;
        }

        if(line.find("<bind>")!=string::npos)
        {
            //<bind>
            i=6;
            line=line.substr(i,line.size());

            while(line.find(" ")!=string::npos)
            {

                vec4 col0, col1, col2, col3;
                col0[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[0]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[0]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[0]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[1]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[1]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[1]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[2]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[2]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[2]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                col0[3]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col1[3]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col2[3]=strtof(line.c_str(),NULL);
                line=line.substr(line.find(" ")+1,line.size());
                col3[3]=strtof(line.c_str(), NULL);
                line=line.substr(line.find(" ")+1,line.size());

                mat4x4 m(col0,col1,col2,col3);

                mbind.push_back(m);
            }
            continue;
        }



        if(line.find("<skeleton>")!=string::npos)
        {

            vector < vector <mat4x4> > mstack;
            vector <mat4x4> mcurr;

            int id=1;
            double d;

            mcurr.reserve(matrixTable[1].size());

            vec4 v0(1,0,0,0);
            vec4 v1(0,1,0,0);
            vec4 v2(0,0,1,0);
            vec4 v3(0,0,0,1);

            mat4x4 identity(v0,v1,v2,v3);
            for(i=0; i<mcurr.size(); i++)
            {
                mcurr[i]=identity;
            }


            while(line.find("</skeleton>")==string::npos)
            {
                std::getline(xml,line);
                if(line.find("<node")!=string::npos)
                {
                    mstack.push_back(mcurr);
                    //read id
                    i=line.find("=")+1;
                    d=strtod(line.substr(i,line.size()).c_str(),NULL);
                    id=(int)d;

                    matrixTable[id]=applyMul(matrixTable[id],mcurr);
                    mcurr=matrixTable[id];
                }
                if(line.find("</node>")!=string::npos)
                {
                    mcurr=mstack[mstack.size()-1];
                    mstack.pop_back();

                }
            }

            continue;
        }

        if(line.find("<frameskip>")!=string::npos)
        {
            //<frameskip>0
            i=11;
            line=line.substr(i,line.size());
            skip=strtod(line.c_str(),NULL);
            continue;
        }

        if(line.find("<framestart>")!=string::npos)
        {
            //<framestart>0
            i=12;
            line=line.substr(i,line.size());
            fstart=strtod(line.c_str(),NULL);
            continue;
        }

        if(line.find("<frameend>")!=string::npos)
        {
            //<frameend>0
            i=10;
            line=line.substr(i,line.size());
            fend=strtod(line.c_str(),NULL);
            continue;
        }

        if(line.find("<scale>")!=string::npos)
        {
            //<scale>
            i=7;
            line=line.substr(i,line.size());

            scale4[0]=strtof(line.c_str(), NULL);
            line=line.substr(line.find(" ")+1,line.size());
            scale4[1]=strtof(line.c_str(),NULL);
            line=line.substr(line.find(" ")+1,line.size());
            scale4[2]=strtof(line.c_str(),NULL);
            scale4[3]=1;

            printf("scale : %f %f %f \n", scale4[0],scale4[1],scale4[2]);

            scale3[0]=scale4[0];
            scale3[1]=scale4[1];
            scale3[2]=scale4[2];
        }
    }
    printf("START : %d %d %d\n", bcount,fstart,fend);

    vector <vec3> vertex_normal;

    //compute vertex normal
    unsigned int j;
    vertex_normal.reserve(vertex.size());
    for(i=0;i<triangle.size()/3;i++)
    {
         for(j=0;j<3;j++) {
             vertex_normal[triangle[i*3+j].x]+=normalize(normal[triangle[i*3].y]+normal[triangle[i*3+1].y]+normal[triangle[i*3+2].y]);}
     }
    for(i=0;i<vertex.size();i++)
        vertex_normal[i]=normalize(vertex_normal[i]);    
    
    
    //output dataset to file.
    ofstream out("XML.asm");
    vector <mat4> mset;
    vector <int> rvlink;

    rvlink.reserve(link.size());

    // with link information, we also need to sort triangle
    
    vector <pair <int, int> > tlink;
	tlink.reserve(triangle.size()/3);
	
	for(i=0; i<triangle.size()/3; i++)
	{
		tlink[i].second = i;
		tlink[i].first = link[triangle[i*3].x].first;	//bone id
	}
	sort(tlink.begin(),tlink.end());
    
    int prev=-1;
    j=0;

/*; mesh format :
; db option
; db bone_count
; dl vertex_stream, triangle_stream */

    int option = TEXTURE | NORMAL | MATRIX;

    out << "db " << option << '\n'; 
    out << "db " << bcount << '\n';

    for(i=0;i<bcount;i++)
        out << "dl vertex_stream" << i << ",index_stream" << i << "\n";
    
    
    out << "vertex_stream0:" << '\n';
    out << "db " << option << '\n'; 
    out << "dl " << vertex.size() << "\n";

    for(i=0; i<vertex.size(); i++)
    {
        if(prev!=link[i].first)
        {
            if(prev!=-1){
                out << "db 1" << '\n';
                out << "vertex_stream" << link[i].first << ":\n";
                out << "db " << option << '\n'; 
                out << "dl " << vertex.size() << '\n';
            }
            prev=link[i].first;
            //write matrix data : FUN
            mset=matrixTable[prev];
            out << "db " << fend-fstart << "\n";
            int s = mset.size();
            //fend = std::min(fend,s);
            //if(fend==0)
            //    fend=(int)mset.size();

            printf("%d %d %d\n", fend,s, prev);

            for(j=fstart; j<fend; j++)
            {

                mat4 m=mswap*mset[j]*mbind[prev];

               // vec4 col0=m[0];
               // vec4 col1=m[1];
               // vec4 col2=m[2];
                vec4 col3=m[3]*scale4;

                   vec4 x0=m[0];
    vec3 incol0(x0[0],x0[1],x0[2]);
    vec4 x1=m[1];
    vec3 incol1(x1[0],x1[1],x1[2]);
    vec4 x2=m[2];
    vec3 incol2(x2[0],x2[1],x2[2]);

    vec3 col0=normalize(incol0);
    vec3 col1=normalize(incol1-dot(incol1,col0)*col0);
    vec3 col2=incol2 - dot(incol2,col0)*col0;
    col2-=dot(col2,col1)*col1;
    col2=normalize(col2);

                out << "db ";
                out << (int)(col0[0]*64.0) <<  "," << (int)(col1[0]*64.0) <<  "," << (int)(col2[0]*64.0) << "\n";
                out << "db ";
                out << (int)(col0[1]*64.0) <<  "," << (int)(col1[1]*64.0) <<  "," << (int)(col2[1]*64.0) << "\n";
                out << "db ";
                out << (int)(col0[2]*64.0) <<  "," << (int)(col1[2]*64.0) <<  "," << (int)(col2[2]*64.0) << "\n";
                out << "dl ";
                out << (int)(col3[0]*256.0*64.0) << "," << (int)(col3[1]*256.0*64.0) << "," << (int)(col3[2]*256.0*64.0) << "\n";
            }
        }

        int b = link[i].second; // vertex id
        rvlink[b]=i;

        vec3 v=vertex[b]*scale3;
    // write vec3 back
        vertex[b]=v;
//        out << ".dw " << (int)(v[0]*256.0) << "," << (int)(v[1]*256.0) << "," << (int)(v[2]*256.0) << "\n";
        
        int sm = sgn(round(v[0]*256.0)) << 7 | ( sgn(round(v[1]*256.0)) << 6) | (sgn(round(v[2]*256.0)) << 5);
	
	if((abs(round(v[0]*256.0))<256) && (abs(round(v[1]*256.0))<256) && (abs(round(v[2]*256.0))<256)) {
	    sm |= 16;    
	}
        out << "db "<< sm << "\n";
        out << "dw ";
        out << abs(round(v[0]*256.0)) << ",";
        out << abs(round(v[1]*256.0)) << ",";
        out << abs(round(v[2]*256.0)) << '\n';
        
        // if(vertex_normal.size()!=0)
        // {
            vec3 n=vertex_normal[b];
            out << "db " << (int)(n[0]*64.0) << "," << (int)(n[1]*64.0) << "," << (int)(n[2]*64.0) << "\n";
        // }

    }
    out << "db 1" << '\n';
    

    prev=-1;
    out << "index_stream0:" << '\n';
    out << "db " << option << '\n'; 
    out << "dl " << (triangle.size()/3) << "\n";
    for(int j=0; j<triangle.size()/3; j++)
	{
	i = tlink[j].second;
	
	if(prev!=tlink[i].first)
	{
		printf("Outputing new bone %d \n", tlink[i].first);
                if(prev!=-1){
                out << "db 1" << '\n';
                out << "index_stream" << tlink[i].first << ":\n";
                out << "db " << option << '\n'; 
                out << "dl " << triangle.size()/3 << '\n';}
                prev=tlink[i].first;
	}
	
    out << "dl " << rvlink[triangle[i*3].x]*16 << "," << rvlink[triangle[i*3+1].x]*16 << "," << rvlink[triangle[i*3+2].x]*16 << "\n";
     vec3 edge0;
     vec3 edge1;
     edge0 = vertex[rvlink[triangle[i*3].x]] - vertex[rvlink[triangle[i*3+1].x]];
     edge1 = vertex[rvlink[triangle[i*3].x]] - vertex[rvlink[triangle[i*3+2].x]];
     // TODO : flip normal
     vec3 norm=normalize(cross(edge0,edge1));
     vec3 cst(-31.0,-31.0,-31.0);
     vec3 cst2(256.0,256.0,256.0);
     norm = norm * cst;
     vec3 point = vertex[rvlink[triangle[i*3].x]] * cst2;
     out << "db " << ((int)round(norm[0]))*4 << ',' << ((int)round(norm[1])*4) << ',' << ((int)round(norm[2]))*4 << '\n';
     out << "dl " << -round(dot(norm,point)) << '\n';

    ivec2 tcoord=map_texture(texture[triangle[i*3].z]);
    out << "db " << tcoord[0] << "," << tcoord[1] << "\n";
    tcoord=map_texture(texture[triangle[i*3+1].z]);
    out << "db " << tcoord[0] << "," << tcoord[1] << "\n";
    tcoord=map_texture(texture[triangle[i*3+2].z]);
    out << "db " << tcoord[0] << "," << tcoord[1] << "\n";
	}
	out << "db 1";

}

vector <mat4x4> applyMul(vector <mat4x4> right, vector <mat4x4> left)
{
    unsigned int i;
    for(i=0; i<std::min(right.size(),left.size()); i++)
    {
        right[i]=left[i]*right[i];
    }
    return right;
}

// ivec2 UVMap(vec2 t)
// {
//     ivec2 newcoord(clamp((int)(clamp(t[0],0.0f,1.0f)*256.0),0,255), clamp((int)(clamp(1.0f-t[1],0.0f,1.0f)*256.0),0,255));
//     return newcoord;
// }

ivec2 map_texture(vec2 texcoord)
{
    ivec2 texture;
    texture.x=(int)round(glm::clamp(texcoord.x*256.0f,0.0f,255.0f));
    texture.y=(int)round(glm::clamp((1.0f-texcoord.y)*256.0f,0.0f,255.0f));
    return texture;
}

void display_vector(const vector<int> &v)
{
    std::copy(v.begin(), v.end(),
        std::ostream_iterator<int>(std::cout, " "));
}
