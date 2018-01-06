#include <climits>
#include <cstdlib>
#include <string>
#include <string.h>
#include <ios>
#include <iostream>
#include <fstream>
#include <vector>
#include "glm/glm.hpp"

#define MAX_LINE_SIZE 16777216


using namespace std;
using namespace glm;
vector <mat4x4> applyMul(vector <mat4x4> right,vector <mat4x4> left);
ivec2 UVMap(vec2 t);

int main()
{
    mat4 mswap(1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1);
    double skip;
    vec4 scale4(1,1,1,1);
    vec3 scale3(1,1,1);

    ifstream xml("FILE.xml", std::ios::in);
    if(!xml)
        exit(EXIT_FAILURE);

    string line;
    vector <vec3> vertex;
    vector <vec2> texture;
    vector <vec3> normal;
    vector <ivec3> triangle;
    vector <vec2> link;
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
                link.push_back(p);
            }
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

            mat4x4 m=matrixTable[8][0];

            vec4 v=m[0];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[1];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[2];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[3];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);





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

            m=matrixTable[8][0];

            v=m[0];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[1];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[2];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);
            v=m[3];
            printf("%f %f %f %f\n", v[0],v[1],v[2],v[3]);


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

        if(line.find("<scale>")!=string::npos)
        {
            //<scale>
            i=7;
            line=line.substr(i,line.size());
            puts(line.c_str());

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
    printf("%d", bcount);

    //output dataset to file.
    ofstream out("XML.ez80");
    vector <mat4> mset;
    int prev=-1;
    int j=0;

    out << "VERTEXDATA:\n";
    out << ".dl " << vertex.size()*256 << "\n";

    for(i=0; i<vertex.size(); i++)
    {
        if(prev!=link[i][0])
        {
            prev=link[i][0];
            //write matrix data : FUN
            out << ".dw VX_ANIMATION_BONE\n";
            mset=matrixTable[prev];
            out << ".db " << mset.size() << "\n";
            for(j=0; j<mset.size(); j++)
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

                out << ".db ";
                out << (int)(col0[0]*64.0) <<  "," << (int)(col1[0]*64.0) <<  "," << (int)(col2[0]*64.0) << "\n";
                out << ".db ";
                out << (int)(col0[1]*64.0) <<  "," << (int)(col1[1]*64.0) <<  "," << (int)(col2[1]*64.0) << "\n";
                out << ".db ";
                out << (int)(col0[2]*64.0) <<  "," << (int)(col1[2]*64.0) <<  "," << (int)(col2[2]*64.0) << "\n";
                out << ".dw ";
                out << (int)(col3[0]*256.0) << "," << (int)(col3[1]*256.0) << "," << (int)(col3[2]*256.0) << "\n";
            }
        }
        vec3 v=vertex[i]*scale3;
        out << ".dw " << (int)(v[0]*256.0) << "," << (int)(v[1]*256.0) << "," << (int)(v[2]*256.0) << "\n";
        if(normal.size()!=0)
        {
            vec3 n=normal[i];
            out << ".db " << (int)(n[0]*64.0) << "," << (int)(n[1]*64.0) << "," << (int)(n[2]*64.0) << "\n";
        }
    }

    out << "TRIDATA:\n";
    out << ".dl " << (triangle.size()/3)*256 << "\n";
    for(i=0; i<triangle.size()/3; i++)
{
    out << ".f " << triangle[i*3].x << "," << triangle[i*3+1].x << "," << triangle[i*3+2].x << "\n";
    out << ".db 0\n";
    ivec2 tcoord=UVMap(texture[triangle[i*3].z]);
    out << ".db " << tcoord[0] << "," << tcoord[1] << "\n";
    tcoord=UVMap(texture[triangle[i*3+1].z]);
    out << ".db " << tcoord[0] << "," << tcoord[1] << "\n";
    tcoord=UVMap(texture[triangle[i*3+2].z]);
    out << ".db " << tcoord[0] << "," << tcoord[1] << "\n";
}


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

ivec2 UVMap(vec2 t)
{
    ivec2 newcoord(clamp((int)(clamp(t[0],0.0f,1.0f)*256.0),0,255), clamp((int)(clamp(1.0f-t[1],0.0f,1.0f)*256.0),0,255));
    return newcoord;
}
