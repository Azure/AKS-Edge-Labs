from flask import Flask, jsonify, request
import subprocess

def call_powershell_cmdlet(cmdlet):
    process = subprocess.Popen(['powershell', cmdlet], stdout=subprocess.PIPE)
    result = process.communicate()
    return result

app = Flask(__name__)

@app.route('/node', methods=['GET'])
def node():
    command = request.args.get('command')
    node = request.args.get('node')
    print("Request received - Command: {} - Node: {}".format(command, node))
    if command not in ['Stop-AksEdgeNode', 'Start-AksEdgeNode']:
        return jsonify({'error': 'Invalid command'}), 400

    # Code to stop or start the node
    if(command == "Start-AksEdgeNode"):
        psCmd = "kubectl uncordon {}".format(node)
    else:
        psCmd = "kubectl drain {} --ignore-daemonsets".format(node)

    result = call_powershell_cmdlet(psCmd)
    if not "Exception" in result:
        return jsonify({'status': 'Success'}), 200  
    else:
        return jsonify({'error': 'Fail to run command'}), 500

if __name__ == '__main__':
    app.run(debug=True)