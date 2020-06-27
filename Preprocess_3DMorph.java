import ij.*;
import ij.gui.*;
import java.awt.*;
import javax.swing.*;
import ij.plugin.PlugIn;
import ij.io.OpenDialog;
import java.util.ArrayList;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.swing.text.StyledDocument;
import ij.process.ImageProcessor;

/* Bio-Formats plugin */
import loci.plugins.macro.LociFunctions;
import loci.plugins.BF;
import loci.plugins.in.ImporterOptions;
import loci.plugins.util.*;


public class Preprocess_3DMorph implements PlugIn {
	/* GUI variables */
	private static NonBlockingGenericDialog prompt;
	private Button addButton;
	private Button outputButton;
	private JLabel outputLabel;
	private JTextField channelField;
	private StyledDocument fileListDoc;
	
	/* Misc class variables */
	private ArrayList<File> fileList; 
	private String lastDirectory = null;
	private String outDirectory = null;
	private int channel = 1;

	@Override
	public void run(String arg) {
		boolean verbose = true; 

		this.fileList = new ArrayList<File>();

		setupFileChooserPrompt(); 
		this.prompt.showDialog();

		if (this.prompt.wasOKed()) {
			if (outDirectory == null) {
				IJ.log("Please select an output directory first!");
				return;
			}
			if (this.channelField == null) {
				return;
			}
			String ch = this.channelField.getText();		
			if (ch == null || ch.length() == 0) {
				IJ.log("Please enter the channel number!");
				return;
			}
			try {
				this.channel = Integer.parseInt(ch);
			}
			catch (Exception e) {
				IJ.log("Please enter a valid channel number!");
				return;
			}
			
			processFiles(verbose);
		}
	}

	private void processFiles(boolean verbose) {
	
		for (File file : this.fileList) {
			String filename = file.getPath(); 
			
			String fileExtension = filename.substring(filename.lastIndexOf('.'));
		
			if (!fileExtension.equals(".oir")) {
				IJ.log(filename + " is not a valid oir file!");
				continue;
			}

			ImagePlus imp = openImage(filename);
			
			IJ.run(imp, "Subtract Background...", "rolling=25 stack");
			while(IJ.macroRunning()) {
				try { wait(1000); }
				catch (Exception e) {}
			}
			IJ.run(imp, "Median 3D...", "x=2 y=2 z=2");
			while(IJ.macroRunning()) {
				try { wait(1000); }
				catch (Exception e) {}
			}

			String outFile = this.outDirectory + File.separator + file.getName() + ".tif";
			IJ.log("Out file: " + outFile); 
			IJ.saveAsTiff(imp, outFile);
			imp.close();
		}
	}

	private void setupFileChooserPrompt() {
		this.prompt = new NonBlockingGenericDialog("Select Files");
		this.prompt.addMessage("Click 'Add Files' to create a list of files to process.\n" 
								+ "Click 'Process Files' when done to process all files "
								+ "on the list.");
		
		this.outputButton = new Button("Output Folder");
		this.outputButton.addActionListener(this.prompt);
		Panel outputPanel = new Panel();
		outputPanel.add(this.outputButton);
		this.outputLabel = new JLabel("<Select>");
		outputPanel.add(this.outputLabel);
		this.prompt.addPanel(outputPanel, GridBagConstraints.WEST,
							 new Insets(10, 20, 0, 0));

		this.channelField = new JTextField("1", 3);
		Panel channelPanel = new Panel();
		channelPanel.add(new JLabel("Channel number to analyze: "));
		channelPanel.add(this.channelField);
		this.prompt.addPanel(channelPanel, GridBagConstraints.WEST,
							 new Insets(10, 20, 0, 0));
							 
		this.addButton = new Button("Add Files");
		this.addButton.addActionListener(this.prompt); 
		Panel buttonPanel = new Panel();
		buttonPanel.add(this.addButton);
		this.prompt.addPanel(buttonPanel, GridBagConstraints.WEST, 
							 new Insets(10, 20, 0, 0));


		Panel fileListPanel = new Panel(); 
		JTextPane fileListText = new JTextPane();
		fileListText.setEditable(false);
		fileListText.setMargin(new Insets(10,10,10,10)); 

		this.fileListDoc = fileListText.getStyledDocument();

		JScrollPane scrollPane = new JScrollPane(fileListText);
		scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPane.setPreferredSize(new Dimension(400, 300));
		scrollPane.setMinimumSize(new Dimension(10, 10));
		fileListPanel.add(scrollPane); 

		this.prompt.addPanel(fileListPanel, GridBagConstraints.WEST, 
							 new Insets(10, 20, 0, 0));

		this.prompt.addDialogListener(promptListener);
		this.prompt.setOKLabel("Process Files");
	}


	DialogListener promptListener = new DialogListener() {

		// This method is invoked by the GenericDialog upon changes
		@Override
		public boolean dialogItemChanged(final GenericDialog ignored, 
										 final AWTEvent e) {
			if (e != null) {
				if (e.getSource() == addButton) {
			
					File[] files = openFileChooser();
					if ((files == null) || (files.length <= 0)) {
						return false;
					}
	
					return updateFileList(files);
				}
				else if (e.getSource() == outputButton) {
					File dir = openDirectoryChooser();
					if ((dir == null) || !dir.isDirectory()) {
						return false;
					}
					return true;
				}
			}

			return true;
		}
	};


	private File[] openFileChooser() {
		if (this.lastDirectory == null) {
			this.lastDirectory = OpenDialog.getLastDirectory();
		}
		// Using FileDialog instead of JFileChooser because JFileChooser locks 
		// up every so often
		FileDialog fd = new FileDialog(IJ.getInstance(), 
										"Choose a file or files"); 
		fd.setDirectory(this.lastDirectory); 
		fd.setMultipleMode(true);
		fd.setVisible(true);
		
		return fd.getFiles();
	}


	private File openDirectoryChooser() {
		if (this.lastDirectory == null) {
			this.lastDirectory = OpenDialog.getLastDirectory();
		}
		
		JFileChooser chooser = new JFileChooser(this.lastDirectory); 
  		chooser.setDialogTitle("Choose a folder for file output");
    	chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

    	if (chooser.showOpenDialog(this.prompt) == JFileChooser.APPROVE_OPTION) { 
      		File dir = chooser.getSelectedFile();
      		if ((dir == null) || !dir.isDirectory()) {
				IJ.log("Invalid selection");
				return null;
      		}
      		else {
      			this.outDirectory = dir.getAbsolutePath();
				this.outputLabel.setText(dir.getName());
				this.lastDirectory = this.outDirectory;
      			return dir;
      		}
      	}
    	else {
    		return null;
      	}
	}


	private boolean updateFileList(File[] files) {
		if (files == null) {
			return false;
		}
		
		for (int i=0; i<files.length; i++) {
			this.fileList.add(files[i]); 
			String nameOnly = files[i].getName() + "\n"; 
			Path p = Paths.get(files[i].toString());
			this.lastDirectory = p.getParent().toString();
			
			try {
            	this.fileListDoc.insertString(this.fileListDoc.getLength(), 
											  nameOnly, null);
        	} 
        	catch (Exception e) {
            	IJ.log("Could not add files to list."); 
            	return false;
        	}
		}

		return true;
	}

	/**
	 * Uses the Bio-Formats library to open a oir image. 
	 * 
	 * The Bio-Formats library is being used programmatically instead of with IJ.run() to avoid
	 * a bug in the library that results in really slow loading of images. 
	 */
	protected ImagePlus openImage(String filename) {
      	ImageProcessorReader reader = new ImageProcessorReader();
      	LociFunctions LF = new LociFunctions(); 

      	IJ.log("Opening image " + filename);
      	
		try { 
    		LF.setId(filename);
    		
			Double[] zsize_d = new Double[1];
			Double[] micronsPerPixel_d = new Double[1];
			Double[] micronsPerZ_d = new Double[1];
			
			LF.getSizeZ(zsize_d);
			LF.getPixelsPhysicalSizeX(micronsPerPixel_d);
			LF.getPixelsPhysicalSizeZ(micronsPerZ_d);
	
			IJ.log("Physical size of X/Y pixels: " + micronsPerPixel_d[0] + " um");
			IJ.log("Z distance: " + micronsPerZ_d[0] + " um"); 

			double z = zsize_d[0];

			IJ.run("Bio-Formats Importer", "open=" + filename + 
					" color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT" + 
					" c_begin=" + this.channel + " c_end=" + this.channel + 
					" c_step=1 z_begin=1 z_end=" + (int)(z) + " z_step=1");
			
			while (IJ.macroRunning()) {
				try { wait(1000); }
				catch (Exception e) {}
			}
			
			ImagePlus imp = IJ.getImage();
			return imp;
		}
		catch (Exception e) {
			IJ.log("Cannot open image: " + e.toString()); 
			return null;
		}
	}
}

