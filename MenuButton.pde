public class MenuButton{
    float x, y, w, h, scale, aWidth, speed;
    int scene, currentScene;
    color primary, secondary;
    String text;
    boolean clicked, hovered, animationFinished;

    /**
     * Constuctor for the MenuButton class. Button is drawn from the center
     * @param x            X pos for the button to be displayed.
     * @param y            Y pos for the button to be displayed.
     * @param scale        Scale the buttons up (above 1) if they are too small.
     * @param text         Text to display in the button
     * @param scene        Scene you wish to transition to.
     * @param currentScene Scene the button currently lives in.
     */
    public MenuButton(float x, float y, float scale, String text, int currentScene, int scene){
        this.x = x;
        this.y = y;
        this.aWidth = 0;
        this.scene = scene;
        this.currentScene = currentScene;
        this.text = text;
        this.scale = scale;
        this.speed = 12 * scale;
        this.w = 150 * scale;
        this.h = 23 * scale;
        this.primary = color(51,51,51);
        this.secondary = color(146,221,200);
        this.clicked = false;
        this.hovered = false;
        this.animationFinished = false;

        PFont font = createFont("AppleSDGothicNeo-Thin-48.vlw", 80);
        textFont(font);
    }

    /**
     * Animation for when the cursor is hovered over the button.
     */
    public void animateHover(){
        //Is the cursor over the button? If so expand the animation rect.
        if (isHovered()){
            //Make sure the animation rect stops growing when it is larger than
            //the button width.
            if (aWidth < w)
                aWidth += speed;
            //Snap the animation rect to the width of the button if it is too large.
            if (aWidth > w)
                aWidth = w;
        }
        //If we are not hovered over the button then shrink the animation rect.
        else{
            //Make sure the animation rect stops shrinking when it is smaller than 0
            if(aWidth > 0)
                aWidth -= speed;
            //Snap the animation rect to the width of the button if it is too small.
            if(aWidth < 0)
                aWidth = 0;
        }

        //Simply draw the rect if it is larger than 0
        if (aWidth > 0){
            rectMode(CORNER);
            fill(secondary);
            rect((x - w/2), y - (h/2), aWidth, h);
        }
    }

    /**
     * Display a click if the button is actually clicked
     * @param s [description]
     */
    public int setClicked(int s){
        //If the mouse is over the button and we are in the current scene of the
        //button.
        if (isHovered() && s == currentScene){
            aWidth = 0;
            cursor(ARROW);
            return scene;
        }
        return -1;
    }

    /**
     * Change the primary color of the button (RGB)
     * @param r red
     * @param g green
     * @param b blue
     */
    public void setPrimary(int r, int g, int b){
        primary = color(r, g, b);
    }

    /**
     * Change the secondary color of the button (RGB)
     * @param r red
     * @param g green
     * @param b blue
     */
    public void setSecondary(int r, int g, int b){
        secondary = color(r, g, b);
    }

    //Display the button to the screen.
    public void show(){
        noStroke();

        fill(primary);
        rectMode(CENTER);
        rect(x, y, w, h);

        animateHover();

        if (aWidth > w/2)
            fill(primary);
        else
            fill(secondary);

        textSize(12 * scale);
        textAlign(CENTER);
        text(text, x, y + (3 * scale));
    }

    /**
     * Set the scene to a different value.
     * @param s Scene number
     */
    public void setScene(int s){
        scene = s;
    }

    /**
     * Set the button text to a differnt value
     * @param s String val
     */
    public void setText(String s){
        text = s;
    }

    /**
     * Check to see if the mouse is hovered over the button.
     * @return [description]
     */
    public boolean isHovered(){
        if (mouseX > x - w/2 && mouseX < x + w/2){
            if (mouseY > y - h/2 && mouseY < y + h/2){
                hovered = true;
                cursor(HAND);
                return true;
            }
        }

        if(hovered)
            cursor(ARROW);

        hovered = false;
        return false;
    }

}
