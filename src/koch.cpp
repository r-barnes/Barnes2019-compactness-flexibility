//Based on code by Bilal Cheema (http://www.cplusplus.com/articles/iE86b7Xj/, https://bacprogramming.wordpress.com/)
#include <list>
#include <iostream>
#include <iomanip>
#include <cmath>

const int SCR_W = 640; // Width of the window
const int SCR_H = 480; // Height of the window

class Line {
 public:
  double x, y, length, angle; // Members

  Line(double x, double y, double length, double angle) : 
    x(x), y(y), length(length), angle(angle)
  {}

  double xf(const double frac) const {
    return x + std::cos(angle)*length/frac;
  }

  double yf(const double frac) const {
    return y + std::sin(angle)*length/frac;
  }

  double getX2() const { // Getting the second x coordinate based on the angle and length
    return x+std::cos(angle)*length;
  }

  double getY2() const { // Getting the second y coordinate based on the angle and length
    return y+std::sin(angle)*length;
  }
};

// std::ostream& operator<<(std::ostream &out, const Line &l) {
//   out<<std::fixed<<std::setprecision(10)<<l.x<<" "
//      <<std::fixed<<std::setprecision(10)<<l.y;
//      //<<std::fixed<<std::setprecision(10)<<l.getX2()<<" "
//      //<<std::fixed<<std::setprecision(10)<<l.getY2();
// }

//Worth noting: It's a heavy function!
void kochFractal( std::list<Line> &lines ){
  //std::list<Line*> newLines; //For getting new Line*(s)
  //std::list<Line*> delLines; //For getting Line*(s) to be deleted

  for(auto itr = lines.begin(); itr != lines.end(); itr){
    const Line &seg = *itr;

    // std::cout<<"ITER IN: ";
    // itr->draw();

    double x_l1   = seg.x;
    double y_l1   = seg.y;
    double len_l1 = seg.length/3;
    double ang_l1 = seg.angle;

    double x_l2   = seg.xf(1.5);
    double y_l2   = seg.yf(1.5);
    double len_l2 = seg.length/3;
    double ang_l2 = seg.angle;
    
    double x_l3   = seg.xf(3.0);
    double y_l3   = seg.yf(3.0);
    double len_l3 = seg.length/3.0;
    double ang_l3 = seg.angle - 300.0*M_PI/180.0;

    double x_l4   = seg.xf(1.5);
    double y_l4   = seg.yf(1.5);
    double len_l4 = seg.length/3.0;
    double ang_l4 = seg.angle - 240.0*M_PI/180.0;

    //All four lines properties are setted above!

    //Fixing bug - Changing Triangle Forming Orientation
    x_l4    = x_l4 + std::cos(ang_l4)*len_l4;
    y_l4    = y_l4 + std::sin(ang_l4)*len_l4;
    ang_l4 -= M_PI;

    //Each line forms four new lines...
    // newLines.push_back( new Line( x_l1, y_l1, len_l1, ang_l1 ) );
    // newLines.push_back( new Line( x_l2, y_l2, len_l2, ang_l2 ) );
    // newLines.push_back( new Line( x_l3, y_l3, len_l3, ang_l3 ) );
    // newLines.push_back( new Line( x_l4, y_l4, len_l4, ang_l4 ) );

    //std::cout<<"eeee\n";
    lines.emplace( itr, x_l1, y_l1, len_l1, ang_l1 ); //->draw();
    lines.emplace( itr, x_l3, y_l3, len_l3, ang_l3 ); //->draw();
    lines.emplace( itr, x_l4, y_l4, len_l4, ang_l4 ); //->draw();
    lines.emplace( itr, x_l2, y_l2, len_l2, ang_l2 ); //->draw();

    // std::cout<<"ITER: ";
    // itr->draw();

    itr = lines.erase(itr);

    // std::cout<<"ITER NEXT: ";
    // itr->draw();

    //...for deleting itself!
    //delLines.push_back( (*itr) );
  }

}


int main( int argc, char** args ){
  std::list<Line> lines; //Note that we do not take Line, we take Line*
   
  //Horizontal line
  //lines.push_back( new Line(SCR_W-10,SCR_H/2.0, SCR_W-20,180.0) );

  //Vertical line
  //lines.push_back( new Line(SCR_W/1.5,10, SCR_H-20,90.0) );

  //Equilateral Triangle for forming Koch Snowflake
  lines.emplace_back(SCR_W-100, 150, SCR_W-200, M_PI); //180 degrees
  lines.emplace_back(100, 150, SCR_W-200, M_PI/3);     //60 degrees
  Line lineS( SCR_W-100, 150, SCR_W-200, 2*M_PI/3);    //120 degrees
  lineS.x     += std::cos(lineS.angle)*lineS.length;
  lineS.y     += std::sin(lineS.angle)*lineS.length;
  lineS.angle -= M_PI;
  lines.push_back( lineS );

  std::cout<<"level,geom"<<std::endl;
  for(int i=0;i<10;i++){
    std::cout<<i<<",\"POLYGON((";
    
    for(const auto &l: lines)
      std::cout<<l.x<<" "<<l.y<<",";

    std::cout<<lines.front().x<<" "<<lines.front().y<<"))\""<<std::endl;

    kochFractal(lines); //Applying Koch Fractal
  }

  return 0;
}