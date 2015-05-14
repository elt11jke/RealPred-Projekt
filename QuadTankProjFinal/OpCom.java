import javax.swing.*;

import java.awt.*;
import java.awt.event.*;

import se.lth.control.*;
import se.lth.control.plot.*;

/** Class that creates and maintains a GUI for the Ball and Beam process. 
Uses two PlotterPanels for the plotters */
public class OpCom {    

	public static final int CVXGEN=0, QPGEN=1;
	private static final double eps = 0.000001;

	private Regul regul;

	private int priority;
	private int mode;
	
	
	// Declarartion of main frame.
	private JFrame frame;

	// Declarartion of panels.
	private BoxPanel guiPanel, plotterPanel, refParPanel, outerParPanel, parPanel;
	private JPanel refParLabelPanel, refParFieldPanel, outerParLabelPanel, outerParFieldPanel, buttonPanel, somePanel, downPanel;
	private PlotterPanel measPanel1,measPanel2,ctrlPanelu1,ctrlPanelu2;
	private JPanel measAndLabelPanel1,measAndLabelPanel2,controlAndLabelPanel1,controlAndLabelPanel2;
	
	private JLabel meas1Label,meas2Label,control1Label,control2Label;
	// Declaration of components.
	private DoubleField ref1DoubleField = new DoubleField(5,3);
	private DoubleField ref2DoubleField = new DoubleField(5,3);
	//private JButton innerApplyButton;

	//private DoubleField outerParKField = new DoubleField(5,3);
	//private DoubleField outerParTiField = new DoubleField(5,3);
	//private DoubleField outerParTdField = new DoubleField(5,3);
	//private DoubleField outerParTrField = new DoubleField(5,3);
	//private DoubleField outerParNField = new DoubleField(5,3);
	//private DoubleField outerParBetaField = new DoubleField(5,3);
	//private DoubleField outerParHField = new DoubleField(5,3);
	//private JButton outerApplyButton;

	private JRadioButton CVXGENModeButton;
	private JRadioButton QPGENModeButton;
	private JButton startButton;
	private JButton stopButton;

	//private boolean hChanged = false;
	private boolean isInitialized = false;

	/** Constructor. */
	public OpCom(int plotterPriority) {
		priority = plotterPriority;
	}

	/** Starts the threads. */
	public void start() {
		measPanel1.start();
		ctrlPanelu1.start();
		measPanel2.start();
		ctrlPanelu2.start();
	}

	/** Sets up a reference to Regul. Called by Main. */
	public void setRegul(Regul r) {
		regul = r;
	}
	public void initializeGUI() {
	/** Creates the GUI. Called from Main. */
	frame = new JFrame("Quad Tank process");

	// Create a panel for the two plotters.
	plotterPanel = new BoxPanel(BoxPanel.VERTICAL);
	// Create PlotterPanels.
	measPanel1 = new PlotterPanel(2, priority);
	measPanel1.setYAxis(10, -10, 2, 20);
	measPanel1.setXAxis(100, 10, 50);
	measPanel1.setUpdateFreq(10);
	
	meas1Label=new JLabel("Tank 1 ");
	
	measPanel2 = new PlotterPanel(2, priority);
	measPanel2.setYAxis(10, -10, 2, 20);
	measPanel2.setXAxis(100, 10, 50);
	measPanel2.setUpdateFreq(10);
	
	meas2Label=new JLabel("Tank 2 ");
	
	ctrlPanelu1 = new PlotterPanel(1, priority);
	ctrlPanelu1.setYAxis(20, -10, 2, 20);
	ctrlPanelu1.setXAxis(100, 10, 50);
	ctrlPanelu1.setUpdateFreq(10);
	
	control1Label=new JLabel("control signal 1 ");
	
	ctrlPanelu2 = new PlotterPanel(1, priority);
	ctrlPanelu2.setYAxis(20, -10, 2, 20);
	ctrlPanelu2.setXAxis(100, 10, 50);
	ctrlPanelu2.setUpdateFreq(10);

	control2Label = new JLabel("control signal 2 ");
    
	//measAndLabelPanel1 = new JPanel(); 
	//measAndLabelPanel2 = new JPanel();
	//controlAndLabelPanel1 = new JPanel();
	//controlAndLabelPanel1 = new JPanel();
	
	
	plotterPanel.add(meas1Label);
	plotterPanel.add(measPanel1);
	
	plotterPanel.add(meas2Label);
	plotterPanel.add(measPanel2);
	
	
	
	plotterPanel.add(control1Label);
	plotterPanel.add(ctrlPanelu1);
	
	
	plotterPanel.add(control2Label);
	plotterPanel.add(ctrlPanelu2);
	
	
	plotterPanel.addFixed(10);
	
	

	// Get initial parameters from Regul
	/*
	innerPar = regul.getInnerParameters();
	outerPar = regul.getOuterParameters();
     */
	// Create panels for the parameter fields and labels, add labels and fields 
	
	//refParPanel = new BoxPanel(BoxPanel.HORIZONTAL);
	//refParLabelPanel = new JPanel();
	//refParLabelPanel.setLayout(new GridLayout(0,1));
	//refParLabelPanel.add(new JLabel(" Tank 1 ref   "));
	//refParLabelPanel.add(new JLabel(" Tank 2 ref   "));
	
	//refParFieldPanel = new JPanel();
	//refParFieldPanel.setLayout(new GridLayout(0,1));
	//refParFieldPanel.add(ref1DoubleField); 
	//refParFieldPanel.add(ref2DoubleField); 

	//refParPanel.add(refParLabelPanel);
	//refParPanel.addGlue();
	//refParPanel.add(refParFieldPanel);
	//refParPanel.addFixed(10);
	
	// Create panel for the radio buttons.
	buttonPanel = new JPanel();
	buttonPanel.setLayout(new FlowLayout());
	buttonPanel.setBorder(BorderFactory.createEtchedBorder());
	// Create the buttons.
	CVXGENModeButton = new JRadioButton("CVXGEN");
	CVXGENModeButton.enable(true);
	QPGENModeButton = new JRadioButton("QPGEN");
	
	startButton=new JButton("START");
	stopButton = new JButton("STOP");
	// Group the radio buttons.
	ButtonGroup group = new ButtonGroup();
	group.add(CVXGENModeButton);
	group.add(QPGENModeButton);

	
	
	// Button action listeners.
	CVXGENModeButton.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			regul.setCVXGENMode();
		}
	});
	QPGENModeButton.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			regul.setQPGENMode();
		}
	});
	
	startButton.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			//regul.shutDown();
			measPanel1.start();
			measPanel2.start();
			ctrlPanelu1.start();
			ctrlPanelu2.start();
			
		}
	});
	
	stopButton.addActionListener(new ActionListener() {
		public void actionPerformed(ActionEvent e) {
			regul.shutDown();
			measPanel1.stopThread();
			measPanel2.stopThread();
			ctrlPanelu1.stopThread();
			ctrlPanelu2.stopThread();
			
			System.exit(0);
		}
	});

	// Add buttons to button panel.
	buttonPanel.add(CVXGENModeButton, BorderLayout.EAST);
	buttonPanel.add(QPGENModeButton, BorderLayout.WEST);
	

	// Panel for parameter panel and radio buttons
	somePanel = new JPanel();
	somePanel.setLayout(new BorderLayout());
	somePanel.add(startButton, BorderLayout.CENTER);
	somePanel.add(stopButton, BorderLayout.SOUTH);

	// Select initial mode.
	
	mode = regul.getMode();
	switch (mode) {
	case CVXGEN:
		CVXGENModeButton.setSelected(true);
		break;
	case QPGEN:
		QPGENModeButton.setSelected(true);
		break;
	}

    

	// Create panel holding everything but the plotters.
	downPanel = new JPanel();
	downPanel.setLayout(new FlowLayout());
	//downPanel.add(refParPanel);
	downPanel.add(buttonPanel);
	downPanel.add(somePanel);

	// Create panel for the entire GUI.
	guiPanel = new BoxPanel(BoxPanel.VERTICAL);
	guiPanel.add(plotterPanel);
	guiPanel.addGlue();
	guiPanel.add(downPanel);

	// WindowListener that exits the system if the main window is closed.
	frame.addWindowListener(new WindowAdapter() {
		public void windowClosing(WindowEvent e) {
			//regul.shutDown();
			measPanel1.stopThread();
			measPanel2.stopThread();
			ctrlPanelu2.stopThread();
			ctrlPanelu1.stopThread();
			System.exit(0);
		}
	});

	// Set guiPanel to be content pane of the frame.
	frame.getContentPane().add(guiPanel, BorderLayout.CENTER);

	// Pack the components of the window.
	frame.pack();

	// Position the main window at the screen center.
	Dimension sd = Toolkit.getDefaultToolkit().getScreenSize();
	Dimension fd = frame.getSize();
	frame.setLocation((sd.width-fd.width)/2, (sd.height-fd.height)/2);

	// Make the window visible.
	frame.setVisible(true);
	
	isInitialized = true;
}

	/** Called by Regul to plot a control signal data point. */
	public synchronized void putControlU1DataPoint(DoublePoint dp) {
		if (isInitialized) {
			ctrlPanelu1.putData(dp.x, dp.y);
		} else {
			DebugPrint("Note: GUI not yet initialized. Ignoring call to putControlDataPoint().");
		}
	}
	/** Called by Regul to plot a control signal data point. */
	public synchronized void putControlU2DataPoint(DoublePoint dp) {
		if (isInitialized) {
			ctrlPanelu2.putData(dp.x, dp.y);
		} else {
			DebugPrint("Note: GUI not yet initialized. Ignoring call to putControlDataPoint().");
		}
	}

	
	/** Called by Regul to plot a measurement data point. */
	public synchronized void putMeasurementTank1DataPoint(PlotData pd) {
		if (isInitialized) {
			measPanel1.putData(pd.x, pd.yref, pd.y);
		} else {
			DebugPrint("Note: GUI not yet initialized. Ignoring call to putMeasurementDataPoint().");
		}
	}
	
	public synchronized void putMeasurementTank2DataPoint(PlotData pd) {
		if (isInitialized) {
			measPanel2.putData(pd.x, pd.yref, pd.y);
		} else {
			DebugPrint("Note: GUI not yet initialized. Ignoring call to putMeasurementDataPoint().");
		}
	}
	
	private void DebugPrint(String message) {
		//System.out.println(message);
	}
}

