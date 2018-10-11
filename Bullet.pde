public class Bullet{
    float x, y, angle, size;
    int count;
    PVector velocity;
    Ship p;

    public Bullet(float x, float y, float angle, Ship p){
        this.x = x;
        this.y = y;
        this.angle = angle - PI/2;
        this.size = 5;
        this.count = 0;
        this.p = p;
        this.velocity = PVector.fromAngle(this.angle);
        this.velocity.mult(8);
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public boolean bound(){
        if (x + size < 0){
            x = width + size;
        }
        else if (x - size > width){
            x = 0 - size;
        }

        if (y + size < 0){
            y = height + size;
        }
        else if (y - size > height){
            y = 0 - size;
        }

        if(count > 900){
            return true;
        }
        else{
            count += 8;
            return false;
        }
    }

    public void checkHit(){
        for (Asteroid a : asteroids){
            float distance = dist(a.getX(), a.getY(), x, y);
            if (distance < a.getSize()/2 + size/2){
                p.addScore(a.getScore());
                a.explode();
                count = 1000;
                break;
            }
        }
    }

    public void show(){
        pushMatrix();
        ellipseMode(CENTER);
        translate(x, y);
        travel();
        noStroke();
        fill(255);
        ellipse(0, 0, size, size);
        popMatrix();
        checkHit();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

}
